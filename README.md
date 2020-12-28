# github_repos_analysis

## やりたいこと

組織のリポジトリの言語比率情報を知りたい。

## 前提

[REST API のリソース](https://docs.github.com/ja/free-pro-team@latest/rest/overview/resources-in-the-rest-api)を読むこと。

## 使い方

```bash
$ cd /path/to/work
$ git clone https://github.com/mfham/github_repos_analysis.git
$ cd github_repos_analysis

$ ruby -v
ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin18]
$ bundle --version
Bundler version 2.2.3

$ bundle config set --local path 'vendor/bundle' 
$ bundle config set --local jobs 4
$ bundle install

$ mv .env_sample .env
$ emacs .env
$ bundle exec ruby analyze.rb
```
