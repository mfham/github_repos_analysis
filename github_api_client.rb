require 'faraday'
require 'dotenv/load'
require 'json'

# GitHub API Client
class GitHubApiClient
  URL = 'https://api.github.com'.freeze

  # Faraday::Connectionインスタンスを取得する
  #
  # @return [Faraday::Connection] Faraday::Connectionインスタンス
  def conn
    @conn ||= Faraday.new(
      URL,
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'Authorization': "token #{ENV['GITHUB_PERSONAL_TOKEN']}",
        'User-Agent': ENV['USER_NAME']
      }
    )
  end

  # リポジトリ主要言語を取得する
  #
  # @param  [Hash] repos_info リポジトリ情報
  # @return [String] リポジトリ主要言語
  def main_language(repos_info)
    # 例: 'Ruby'
    repos_info['language']
  end

  # リポジトリ名を取得する
  #
  # @param  [Hash] repos_info リポジトリ情報
  # @return [String] リポジトリ名
  def repository_name(repos_info)
    # 例: 'Ruby'
    repos_info['name']
  end

  # リポジトリ言語比率を取得する
  #
  # @param  [Hash] repos_info リポジトリ情報
  # @return [Hash] リポジトリ言語比率
  def languages_percentages(repos_info)
    langs = JSON.parse(conn.get(repos_info['languages_url']).body)
    bytes_sum = langs.values.sum

    # 例: {'Ruby'=>0.76, 'HTML'=>0.18, 'JavaScript'=>0.06}
    langs.transform_values { |v| (v.to_f / bytes_sum).round(2) }
  end

  # contributor名を取得する
  #
  # @param  [Hash] contributor_info contributor情報
  # @return [String] contributor名
  def contributor_name(contributor_info)
    contributor_info['login']
  end

  # 組織のリポジトリ情報を取得する
  #
  # @param  [String]  org   組織名
  # @return [Hash]    組織のリポジトリ情報
  def repositories_by_organization(org)
    repositories = []

    # 念のため10ページ分に抑える
    (1..10).each do |page|
      repos = JSON.parse(conn.get("orgs/#{org}/repos", { per_page: 100, page: page }).body)
      break if repos.empty?

      repositories += repos
    end

    # 例: [{"id"=>1, ..., "language": "Ruby"}, ..., {"id"=>333, ..., "language": nil}]
    repositories
  end

  # 組織のリポジトリ主翼言語総数を取得する
  #
  # @param  [String]  org   組織名
  # @param  [Integer] limit 取得する件数
  # @return [Hash]    組織のリポジトリ主翼言語総数
  def main_languages_by_organization(org)
    # 例: {"Ruby"=>52, "JavaScript"=>6, "CSS"=>5}
    repositories_by_organization(org)
      .map { |repos| main_language(repos) }
      .reject(&:nil?)
      .group_by(&:itself)
      .transform_values(&:count)
  end

  # 組織のリポジトリ言語比率を取得する
  #
  # @param  [String]  org   組織名
  # @return [Hash]    組織のポジトリ言語比率
  def languages_percentages_by_organization(org)
    # 例: [{"Ruby"=>1.0}, {"CSS"=>0.76, "HTML"=>0.14, "JavaScript"=>0.08, "Ruby"=>0.01, "Shell"=>0.0}, {"Ruby"=>1.0}]
    langs_ratios = repositories_by_organization(org)
      .map { |repos| languages_percentages(repos) }
      .reject(&:empty?)

    cnt = langs_ratios.size
    # 例: {"Ruby"=>2.01, "CSS"=>0.76, "HTML"=>0.14, "JavaScript"=>0.08, "Shell"=>0.0}
    sum = langs_ratios.each_with_object({}) do |langs, res|
      langs.each do |k, v|
        res[k] = res.key?(k) ? res[k] + v : v
      end
    end

    # 例: {"Ruby"=>67.0, "CSS"=>25.33, "HTML"=>4.67, "JavaScript"=>2.67, "Shell"=>0.0}
    sum.transform_values { |v| ((v * 100) / cnt).round(2) }
  end
  
  # リポジトリ主要言語ごとのcontributor情報を取得する
  #
  # @param  [String]  org   組織名
  # @return [Hash]    リポジトリ主要言語ごとのcontributor情報
  def contributors_per_main_languages(org)
    tally = {}

    # [{"PHP": [a,b,c]}, {"Ruby": [x,y]}, ..., {"PHP": [a,x]}]
    lang_contributors = repositories_by_organization(org).map do |repos|
      { main_language(repos) => repositoriy_contributors(org, repository_name(repos)).map { |c| contributor_name(c) } }
    end

    # 言語ごとに集計
    lang_contributors.each do |v|
      v.each do |lang, names|
        tally[lang] = [] unless tally.key?(lang)
        tally[lang] |= names # 重複なし
      end
    end

    tally
  end

  # 指定したリポジトリのcontributor情報を取得する
  #
  # @param  [String]  org 組織名
  # @param  [String]  repository_name リポジトリ名
  # @return [Hash]    指定したリポジトリのcontributor情報
  def repositoriy_contributors(org, repository_name)
    contributors = []

    # 念のため3ページ分に抑える
    (1..3).each do |page|
      response = conn.get("repos/#{org}/#{repository_name}/contributors", { per_page: 100, page: page }).body
      break if response.empty? # 作成して未コミットのリポジトリに対して呼び出すと結果が空文字になる

      contributor = JSON.parse(response)
      break if contributor.empty?

      contributors += contributor
    end

    # 例: [{"id"=>1, ..., "language": "Ruby"}, ..., {"id"=>333, ..., "language": nil}]
    contributors
  end
end
