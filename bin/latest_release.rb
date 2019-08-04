#!/usr/bin/env ruby

require "net/http"
require "json"
require "uri"

GITHUB_API_URL = "https://api.github.com/graphql"

def run_query(params)
  repo_name = params.fetch(:repo_name)
  token = params.fetch(:token)

  json = {query: latest_release_query(repo_name)}.to_json
  headers = {"Authorization" => "bearer #{token}"}

  uri = URI.parse(GITHUB_API_URL)
  resp = Net::HTTP.post(uri, json, headers)

  resp.body
end

def latest_release_query(repo_name)
  owner, name = repo_name.sub("https://github.com/", "").split("/")

  %[
    {
      repository(owner: "#{owner}", name: "#{name}") {
        id
        description
        releases(last: 1) {
          edges {
            node {
              id
              publishedAt
              description
              isDraft
              tagName
              url
            }
          }
        }
      }
    }
  ]
end

############################################################

json = run_query(
  repo_name: "uswitch/kiam",
  token: ENV.fetch("GITHUB_ACCESS_TOKEN")
)

puts json
