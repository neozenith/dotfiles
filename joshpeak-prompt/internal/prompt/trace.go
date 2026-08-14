package prompt

import (
	"context"
	"sort"
	"strings"
	"sync"
	"time"
)

type Span struct {
	Operation   string
	StartOffset time.Duration
	Duration    time.Duration
}

type spanRecorder struct {
	origin time.Time
	now    func() time.Time
	mu     sync.Mutex
	spans  []Span
}

type spanRecorderKey struct{}

type sharedRuns struct {
	mu         sync.Mutex
	calls      map[string]*sharedCall
	recorder   *spanRecorder
	repository *repositoryCall
}

type sharedCall struct {
	done   chan struct{}
	output string
}

type sharedRunsKey struct{}

func withSpanRecorder(ctx context.Context, recorder *spanRecorder) context.Context {
	return context.WithValue(ctx, spanRecorderKey{}, recorder)
}

func withSharedRuns(ctx context.Context, shared *sharedRuns) context.Context {
	return context.WithValue(ctx, sharedRunsKey{}, shared)
}

func runWithSpan(ctx context.Context, runner Runner, operation, name string, args ...string) string {
	return recordSpan(ctx, operation, func() string {
		return runner.Run(ctx, name, args...)
	})
}

func runSharedWithSpan(ctx context.Context, runner Runner, operation, name string, args ...string) string {
	shared, _ := ctx.Value(sharedRunsKey{}).(*sharedRuns)
	if shared == nil {
		return runWithSpan(ctx, runner, operation, name, args...)
	}
	return func() string {
		key := strings.Join(append([]string{name}, args...), "\x00")
		shared.mu.Lock()
		call, exists := shared.calls[key]
		if !exists {
			call = &sharedCall{done: make(chan struct{})}
			shared.calls[key] = call
		}
		shared.mu.Unlock()
		if exists {
			select {
			case <-call.done:
				return call.output
			case <-ctx.Done():
				return ""
			}
		}
		sharedContext := withSpanRecorder(ctx, shared.recorder)
		call.output = runWithSpan(sharedContext, runner, operation, name, args...)
		close(call.done)
		return call.output
	}()
}

func recordSpan(ctx context.Context, operation string, run func() string) string {
	recorder, _ := ctx.Value(spanRecorderKey{}).(*spanRecorder)
	if recorder == nil {
		return run()
	}
	start := recorder.now()
	output := run()
	finish := recorder.now()
	recorder.mu.Lock()
	recorder.spans = append(recorder.spans, Span{
		Operation:   operation,
		StartOffset: start.Sub(recorder.origin),
		Duration:    finish.Sub(start),
	})
	recorder.mu.Unlock()
	return output
}

func (r *spanRecorder) snapshot() []Span {
	r.mu.Lock()
	defer r.mu.Unlock()
	spans := append([]Span(nil), r.spans...)
	sort.SliceStable(spans, func(i, j int) bool {
		if spans[i].StartOffset == spans[j].StartOffset {
			return spans[i].Operation < spans[j].Operation
		}
		return spans[i].StartOffset < spans[j].StartOffset
	})
	return spans
}

func runParallel(tasks ...func()) {
	var wg sync.WaitGroup
	wg.Add(len(tasks))
	for _, task := range tasks {
		go func(task func()) {
			defer wg.Done()
			task()
		}(task)
	}
	wg.Wait()
}
