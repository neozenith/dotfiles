#!/usr/bin/env bash
# Claude Code status line script
# Reads JSON from stdin and formats a status line

input=$(cat)

jq -r '
  # Session identifier: prefer session_name, fall back to session_id
  (.session_name // .session_id // "") as $session |

  # Model
  ("[" + .model.display_name + "]") as $model |

  # Token counts and context usage
  ("In: " + (.context_window.total_input_tokens // 0 | tostring) +
   " | Out: " + (.context_window.total_output_tokens // 0 | tostring) +
   " | " + ((.context_window.used_percentage // 0) | floor | tostring) + "% ctx") as $ctx |

  # Current working directory
  (.cwd // "") as $cwd |

  # App version
  ("v" + (.version // "")) as $ver |

  # Rate limits (optional, Claude.ai subscribers only)
  (
    (.rate_limits.five_hour.used_percentage | select(. != null) | floor | tostring + "% 5h") // null
  ) as $five_h |
  (
    (.rate_limits.seven_day.used_percentage | select(. != null) | floor | tostring + "% 7d") // null
  ) as $seven_d |
  (
    if $five_h != null and $seven_d != null then " [" + $five_h + " | " + $seven_d + "]"
    elif $five_h != null then " [" + $five_h + "]"
    elif $seven_d != null then " [" + $seven_d + "]"
    else ""
    end
  ) as $limits |

  # Assemble: session prefix only when non-empty
  (if $session != "" then $session + " " else "" end) +
  $model + " " + $ctx + " | " + $cwd + " | " + $ver + $limits
' <<< "$input"
