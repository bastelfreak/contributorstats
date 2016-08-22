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
  json = Net::HTTP.get(uri)
  json = JSON.parse(json)
  json.each do |u|
    additions_count = 0
    deletions_count = 0
    commits_count = 0
    #p u
    user = u['author']['login']
    alllll_the_data[user] = {} unless alllll_the_data[user]
    u['weeks'].each do |w|
      additions_count += w['a']
      deletions_count += w['d']
      commits_count += w['c']
    end
    alllll_the_data[user][repo] = {additions: additions_count, deletions: deletions_count, commits: commits_count}
    puts "user #{user} made: #{alllll_the_data[user][repo]} in repo #{repo}" if user == 'bastelfreak'
    #exit
    #p {additions: additions, deletions: deletions, commits: commits}
    #puts "#{u['author']['login']} #{a.to_s}, #{d.to_s} #{c.to_s}"
  end
#  puts alllll_the_data
#  break
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
