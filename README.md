# TwitterSearch

This script searches for tweets and users on Twitter.

## Setup

Set the following environment variables:

```
TWITTER_SEARCH_CONSUMER_KEY
TWITTER_SEARCH_CONSUMER_SECRET
TWITTER_SEARCH_TOKEN
TWITTER_SEARCH_TOKEN_SECRET
```

You may also need to install the following gems: `simple_oauth`.

## Usage

`$ ruby twitter_search.rb [options]`

The available options are `--tweet QUERY` and `--user QUERY`.