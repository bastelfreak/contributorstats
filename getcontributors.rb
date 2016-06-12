#!/usr/bin/env ruby
#require 'json'
require 'octokit'
#require 'net/http'
require 'yaml'

token = ''
client = Octokit::Client.new(access_token: token)
client.auto_paginate = true
org = 'voxpupuli'
repos = client.org_repos(org).collect{|repo| repo['full_name'] if repo['full_name'] =~ /puppet-.*/}
# remove everything that is nil
repos = repos.select{|repo| repo }
#repos.sort.uniq!
alllll_the_data = {}
repos.each do |repo|
  sleep 2
  puts "processing #{repo}"
  uri = URI("https://api.github.com/repos/#{repo}/stats/contributors?access_token=#{token}")
  json = JSON.parse(Net::HTTP.get(uri))
  json.each do |u|
    additions = 0
    deletions = 0
    commits = 0
    #p u
    user = u['author']['login']
    alllll_the_data[user] = {} unless alllll_the_data[user]
    u['weeks'].each do |w|
      additions += w['a']
      deletions += w['d']
      commits += w['c']
    end
    alllll_the_data[user][repo] = {additions: additions, deletions: deletions, commits: commits}
    #p {additions: additions, deletions: deletions, commits: commits}
    #puts "#{u['author']['login']} #{a.to_s}, #{d.to_s} #{c.to_s}"
  end
end
yamlstuff = alllll_the_data.to_yaml

def commits(yaml_file)
  yaml = YAML.load_file(yaml_file)
  sums = Hash.new { |hash, key| hash[key] = 0 }
  yaml.each do |user, projects|
    projects.each do |_, info|
      sums[user] += info[:commits]
    end
  end
  sums
end

File.open('detailed_stats.yml', 'w') {|f| f.write yamlstuff}
overall = commits('detailed_stats.yml').sort_by {|_key, value| -value}.to_h.to_yaml
File.open('overall_stats.yml', 'w') {|f| f.write overall}

#puts alllll_the_data.first
