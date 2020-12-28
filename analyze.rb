require_relative './github_api_client.rb'

client = GitHubApiClient.new

##### 注意 #####
# https://docs.github.com/ja/free-pro-team@latest/rest/overview/resources-in-the-rest-api
# レート制限があるので、API呼び出し数に注意
###############

organization = 'github'

##### 例1 #####
# リポジトリの主要言語を集計
main_languages = client.main_languages_by_organization(organization)
# リポジトリ数で降順ソートして出力
puts main_languages.sort_by { |_, v| v }.reverse.to_h #=> {"Ruby"=>98, "JavaScript"=>70, ..., "Clojure"=>1}

##### 例2 #####
# リポジトリの言語比率を集計
languages_percentages = client.languages_percentages_by_organization(organization)
# 比率で降順ソートして出力
puts languages_percentages.sort_by { |_, v| v }.reverse.to_h #=> {"Ruby"=>28.86, "JavaScript"=>19.63, ..., "TSQL"=>0.0}
