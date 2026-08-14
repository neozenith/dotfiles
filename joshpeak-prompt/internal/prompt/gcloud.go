package prompt

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"

	_ "modernc.org/sqlite"
)

type TokenReader interface {
	ExpiryDeltaSeconds(context.Context, string, string) (string, error)
}

type SQLiteTokenReader struct{}

var openSQLite = sql.Open

func (SQLiteTokenReader) ExpiryDeltaSeconds(ctx context.Context, databasePath, account string) (string, error) {
	if account == "" {
		return "", nil
	}
	if _, err := os.Stat(databasePath); err != nil {
		return "", nil
	}
	database, err := openSQLite("sqlite", databasePath)
	if err != nil {
		return "", err
	}
	defer database.Close()
	var delta sql.NullInt64
	err = database.QueryRowContext(ctx, `SELECT CAST((julianday(token_expiry) - julianday('now')) * 86400 AS INTEGER) FROM access_tokens WHERE account_id=?`, account).Scan(&delta)
	if err == sql.ErrNoRows {
		return "", nil
	}
	if err != nil {
		return "", err
	}
	if !delta.Valid {
		return "", nil
	}
	return strconv.FormatInt(delta.Int64, 10), nil
}

type GCloud struct {
	Runner Runner
	Env    func(string) string
	Home   string
	Tokens TokenReader
}

func (GCloud) Name() string { return "gcloud" }

func (g GCloud) Render(ctx context.Context) string {
	values := make([]string, 3)
	formats := []string{"value(config.paths.global_config_dir)", "value(config.account)", "value(config.project)"}
	var wg sync.WaitGroup
	for i, format := range formats {
		wg.Add(1)
		go func() {
			defer wg.Done()
			values[i] = g.Runner.Run(ctx, "gcloud", "info", "--format="+format)
		}()
	}
	wg.Wait()
	config, account, project := values[0], values[1], values[2]
	delta := ""
	if g.Tokens != nil && account != "" {
		delta, _ = g.Tokens.ExpiryDeltaSeconds(ctx, config+"/access_tokens.db", account)
	}

	const (
		dark   = "%F{052}"
		bright = "%F{166}"
		valid  = "%F{022}"
	)
	configSource := source(config, g.Env("CLOUDSDK_CONFIG"))
	accountSource := source(account, g.Env("CLOUDSDK_CORE_ACCOUNT"))
	projectSource := source(project, g.Env("CLOUDSDK_CORE_PROJECT"))
	output := ""
	if config == filepath.Join(g.Home, ".config", "gcloud") {
		output = " " + dark + "☁️ gcloud-default" + configSource + norm
	} else {
		display := config
		if g.Home != "" && strings.HasPrefix(display, g.Home) {
			display = "~" + strings.TrimPrefix(display, g.Home)
		}
		output = " " + bright + "☁️ " + display + configSource + norm
	}
	if account != "" || project != "" {
		accountLabel, projectLabel := account, project
		if accountLabel == "" {
			accountLabel = "no-account"
		}
		if projectLabel == "" {
			projectLabel = "no-project"
		}
		output += " " + dark + "(" + accountLabel + accountSource + " ⚡ " + projectLabel + projectSource + ")" + norm
	}
	if account != "" {
		label, colour := "no token", dark
		if delta != "" {
			seconds, err := strconv.ParseInt(delta, 10, 64)
			if err == nil {
				absolute := seconds
				if absolute < 0 {
					absolute = -absolute
				}
				human := humanDuration(absolute)
				if seconds < 0 {
					label = "expired " + human + " ago"
				} else {
					label, colour = human+" left", valid
				}
			}
		}
		output += fmt.Sprintf(" %s🔑 %s%s", colour, label, norm)
	}
	return legacyEcho(output)
}

func source(current, environment string) string {
	if current == "" {
		return ""
	}
	if environment != "" && environment == current {
		return "🌳"
	}
	return "📄"
}

func humanDuration(seconds int64) string {
	switch {
	case seconds < 60:
		return fmt.Sprintf("%ds", seconds)
	case seconds < 3600:
		return fmt.Sprintf("%dm", seconds/60)
	case seconds < 86400:
		return fmt.Sprintf("%dh", seconds/3600)
	default:
		return fmt.Sprintf("%dd", seconds/86400)
	}
}
