require_relative './github_api_client.rb'

client = GitHubApiClient.new

##### 注意 #####
# https://docs.github.com/ja/free-pro-team@latest/rest/overview/resources-in-the-rest-api
# レート制限があるので、API呼び出し数に注意
###############

organization = 'github'
max_repos_number = 400

##### 例1 #####
# リポジトリの主要言語を集計
main_languages = client.main_languages_by_organization(organization, max_repos_number)
# リポジトリ数で降順ソートして出力
puts main_languages.sort_by { |_, v| v }.reverse.to_h #=> {"Ruby"=>52, "Objective-C"=>8, ..., "Clojure"=>1}

##### 例2 #####
# リポジトリの言語比率を集計
languages_percentages = client.languages_percentages_by_organization(organization, max_repos_number)
# 比率で降順ソートして出力
puts languages_percentages.sort_by { |_, v| v }.reverse.to_h #=> {"Ruby"=>55.87, "Objective-C"=>9.05, ..., "XSLT"=>0.0}
