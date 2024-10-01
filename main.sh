#!/bin/bash

set -e

# Fetch environment variables from the inputs
SLACK_WEBHOOK_URL="${INPUT_SLACK_WEBHOOK_URL}"
MESSAGE="${INPUT_MESSAGE:-}"  # Default to empty string if not provided
SLACK_USERNAME="${INPUT_SLACK_USERNAME:-}"
SLACK_ICON_URL="${INPUT_SLACK_ICON_URL:-}"
SLACK_ICON_EMOJI="${INPUT_SLACK_ICON_EMOJI:-}"
SLACK_CHANNEL="${INPUT_SLACK_CHANNEL:-}"
JOB_STATUS="${INPUT_JOB_STATUS:-}"
SLACK_COLOR="${INPUT_SLACK_COLOR:-}"  # Custom color can be passed via this variable
ORG_URL="${INPUT_ORG_URL:-}"
FOOTER="${INPUT_FOOTER:-}"  # Make FOOTER optional
FOOTER_ICON="${INPUT_FOOTER_ICON:-}"  # Make FOOTER_ICON optional
FILE_URL="${INPUT_FILE_URL:-}"
DEPLOYMENT_URL="${INPUT_DEPLOYMENT_URL:-}"

# Custom fields
CUSTOM_FIELD_1_TITLE="${INPUT_CUSTOM_FIELD_1_TITLE:-}"
CUSTOM_FIELD_1_VALUE="${INPUT_CUSTOM_FIELD_1_VALUE:-}"
CUSTOM_FIELD_1_SHORT="${INPUT_CUSTOM_FIELD_1_SHORT:-}"

CUSTOM_FIELD_2_TITLE="${INPUT_CUSTOM_FIELD_2_TITLE:-}"
CUSTOM_FIELD_2_VALUE="${INPUT_CUSTOM_FIELD_2_VALUE:-}"
CUSTOM_FIELD_2_SHORT="${INPUT_CUSTOM_FIELD_2_SHORT:-}"

CUSTOM_FIELD_3_TITLE="${INPUT_CUSTOM_FIELD_3_TITLE:-}"
CUSTOM_FIELD_3_VALUE="${INPUT_CUSTOM_FIELD_3_VALUE:-}"
CUSTOM_FIELD_3_SHORT="${INPUT_CUSTOM_FIELD_3_SHORT:-}"

CUSTOM_FIELD_4_TITLE="${INPUT_CUSTOM_FIELD_4_TITLE:-}"
CUSTOM_FIELD_4_VALUE="${INPUT_CUSTOM_FIELD_4_VALUE:-}"
CUSTOM_FIELD_4_SHORT="${INPUT_CUSTOM_FIELD_4_SHORT:-}"

# Debugging: Echo the variables to ensure they're set correctly
echo "DEBUG: SLACK_WEBHOOK_URL is: '$SLACK_WEBHOOK_URL'"
echo "DEBUG: MESSAGE is: '$MESSAGE'"

# Example environment variables for demo purposes
REF="${GITHUB_REF:-'N/A'}"
EVENT="${GITHUB_EVENT_NAME:-'N/A'}"
REPO_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"  # e.g., https://github.com/user/repo
COMMIT_ID="${GITHUB_SHA:-'N/A'}"  # Get the full commit ID (SHA)
SHORT_COMMIT_ID=$(echo "$COMMIT_ID" | cut -c1-7)  # Get the first 7 characters for short commit ID
SHORT_COMMIT_URL="${REPO_URL}/commit/${COMMIT_ID}"  # e.g., https://github.com/user/repo/commit/10e97f

# Construct the Actions URL using environment variables
GITHUB_RUN_ID="${GITHUB_RUN_ID:-'N/A'}"  # Get the run ID from environment
REPO_ACTION_URL="${REPO_URL}/actions/runs/${GITHUB_RUN_ID}"

# Get the GitHub username of the user who triggered the action
GITHUB_ACTOR="https://github.com/${GITHUB_ACTOR}"

 # Default to 'unknown' if not set

# Define a map of predefined colors for various job statuses
declare -A COLORS
COLORS=(
  ["success"]="#00FF00"  # Green for success
  ["failure"]="#FF0000"  # Red for failure
  ["cancelled"]="#808080"  # Gray for cancelled
)

# Determine the color based on job status, or use the provided custom color
if [[ -n "$SLACK_COLOR" ]]; then
  # If a custom color is provided, use it
  SLACK_COLOR="$SLACK_COLOR"
else
  # Otherwise, use the predefined color based on job status
  SLACK_COLOR="${COLORS[${JOB_STATUS,,}]}"  # Convert to lowercase and fetch the color
fi

# If no color was found, set a default color (blue)
[ -z "$SLACK_COLOR" ] && SLACK_COLOR="#0000FF"

# Trim SLACK_ICON_URL
TRIMMED_SLACK_ICON_URL=$(echo "$SLACK_ICON_URL" | xargs)

# Start creating the JSON payload for the Slack message
JSON_PAYLOAD=$(cat <<EOF
{
  "username": "$SLACK_USERNAME",
EOF
)

# Decide whether to use trimmed icon_url or icon_emoji
if [[ -n "$TRIMMED_SLACK_ICON_URL" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
  "icon_url": "$TRIMMED_SLACK_ICON_URL",
EOF
)
elif [[ -n "$SLACK_ICON_EMOJI" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
  "icon_emoji": "$SLACK_ICON_EMOJI",
EOF
)
fi

# Continue adding other message elements
JSON_PAYLOAD+=$(cat <<EOF
  "channel": "$SLACK_CHANNEL",
  "attachments": [
    {
      "color": "$SLACK_COLOR",
      "fields": [
        {
          "value": "$GITHUB_ACTOR",
          "short": true
        },
        {
          "title": "Ref",
          "value": "$REF",
          "short": true
        },
        {
          "title": "Event",
          "value": "$EVENT",
          "short": true
        },
        {
          "title": "Actions URL",
          "value": "<$REPO_ACTION_URL|Slack_workflow>",
          "short": true
        },
        {
          "title": "Commit",
          "value": "<$SHORT_COMMIT_URL|$SHORT_COMMIT_ID>",
          "short": true
        },
EOF
)

# Optional message field
if [[ -n "$MESSAGE" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
        {
          "title": "Message",
          "value": "$MESSAGE",
          "short": false
        },
EOF
)
fi

# Add the File URL if present
TRIMMED_FILE_URL=$(echo "$FILE_URL" | xargs)
if [[ -n "$TRIMMED_FILE_URL" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
        {
          "title": "File URL",
          "value": "<$TRIMMED_FILE_URL>",
          "short": false
        },
EOF
)
fi

# Add Organization URL if present
TRIMMED_ORG_URL=$(echo "$ORG_URL" | xargs)
if [[ -n "$TRIMMED_ORG_URL" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
        {
          "title": "Organization",
          "value": "$TRIMMED_ORG_URL",
          "short": false
        },
EOF
)
fi

# Check and add Deployment URL if present
TRIMMED_DEPLOYMENT_URL=$(echo "$DEPLOYMENT_URL" | xargs)
if [[ -n "$TRIMMED_DEPLOYMENT_URL" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
        {
          "title": "Deployment URL",
          "value": "<$TRIMMED_DEPLOYMENT_URL>",
          "short": false
        },
EOF
)
fi

# Add custom fields if provided
if [[ -n "$CUSTOM_FIELD_1_TITLE" && -n "$CUSTOM_FIELD_1_VALUE" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
        {
          "title": "$CUSTOM_FIELD_1_TITLE",
          "value": "$CUSTOM_FIELD_1_VALUE",
          "short": $CUSTOM_FIELD_1_SHORT
        },
EOF
)
fi

if [[ -n "$CUSTOM_FIELD_2_TITLE" && -n "$CUSTOM_FIELD_2_VALUE" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
        {
          "title": "$CUSTOM_FIELD_2_TITLE",
          "value": "$CUSTOM_FIELD_2_VALUE",
          "short": $CUSTOM_FIELD_2_SHORT
        },
EOF
)
fi

if [[ -n "$CUSTOM_FIELD_3_TITLE" && -n "$CUSTOM_FIELD_3_VALUE" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
        {
          "title": "$CUSTOM_FIELD_3_TITLE",
          "value": "$CUSTOM_FIELD_3_VALUE",
          "short": $CUSTOM_FIELD_3_SHORT
        },
EOF
)
fi

if [[ -n "$CUSTOM_FIELD_4_TITLE" && -n "$CUSTOM_FIELD_4_VALUE" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
        {
          "title": "$CUSTOM_FIELD_4_TITLE",
          "value": "$CUSTOM_FIELD_4_VALUE",
          "short": $CUSTOM_FIELD_4_SHORT
        },
EOF
)
fi

# Remove the last trailing comma from the fields section
JSON_PAYLOAD=$(echo "$JSON_PAYLOAD" | sed '$s/,$//')

# Add footer section inside the 'attachments' block if provided
TRIMMED_FOOTER=$(echo "$FOOTER" | xargs)
TRIMMED_FOOTER_ICON=$(echo "$FOOTER_ICON" | xargs)

if [[ -n "$TRIMMED_FOOTER" ]]; then
  JSON_PAYLOAD+=$(cat <<EOF
      ],
      "footer": "$TRIMMED_FOOTER"
EOF
  )

  if [[ -n "$TRIMMED_FOOTER_ICON" ]]; then
    JSON_PAYLOAD+=$(cat <<EOF
      ,
      "footer_icon": "$TRIMMED_FOOTER_ICON"
EOF
    )
  fi
else
  JSON_PAYLOAD+=$(cat <<EOF
      ]
EOF
  )
fi

# Close the 'attachments' block
JSON_PAYLOAD+=$(cat <<EOF
    }
  ]
}
EOF
)

# Debugging: Echo the JSON payload to ensure it looks correct
echo "DEBUG: Final JSON payload:"
echo "$JSON_PAYLOAD"

# Send the message to Slack
echo "$JSON_PAYLOAD" | curl -X POST -H 'Content-type: application/json' --data @- "$SLACK_WEBHOOK_URL"
