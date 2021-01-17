require_relative './github_api_client.rb'
require 'json'

client = GitHubApiClient.new

##### 注意 #####
# https://docs.github.com/ja/free-pro-team@latest/rest/overview/resources-in-the-rest-api
# レート制限があるので、API呼び出し数に注意
###############

organization = 'USArmyResearchLab'

##### 例1 #####
# リポジトリの主要言語を集計
main_languages = client.main_languages_by_organization(organization)
# リポジトリ数で降順ソートして出力
puts main_languages.sort_by { |_, v| v }.reverse.to_h.to_json #=> {"Ruby"=>98, "JavaScript"=>70, ..., "Clojure"=>1}

##### 例2 #####
# リポジトリの言語比率を集計
languages_percentages = client.languages_percentages_by_organization(organization)
# 比率で降順ソートして出力
puts languages_percentages.sort_by { |_, v| v }.reverse.to_h.to_json #=> {"Ruby"=>28.86, "JavaScript"=>19.63, ..., "TSQL"=>0.0}

##### 例3 #####
# リポジトリ主要言語ごとのcontributor情報
contributors_per_main_languages = client.contributors_per_main_languages(organization)
puts contributors_per_main_languages.to_json
# contributorごとのリポジトリ主要言語
main_languages_per_contributors = {}
contributors_per_main_languages.each do |lang, names|
  names.each do |name|
    main_languages_per_contributors[name] = [] unless main_languages_per_contributors.key?(name)
    main_languages_per_contributors[name] << lang
  end
end
puts Hash[main_languages_per_contributors.sort].to_json # 名前順
puts Hash[main_languages_per_contributors.sort { |a, b| b[1].size <=> a[1].size} ].to_json # 主要言語数順
