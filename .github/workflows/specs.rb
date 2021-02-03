name: Specs
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
services:
      postgres:
        image: postgres:12
        ports: ["5432:5432"]
        env:
          POSTGRES_PASSWORD: password
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
steps:
    - name: Checkout Repository
      uses: actions/checkout@v2
- name: Set up Ruby
      uses: ruby/setup-ruby@ec106b438a1ff6ff109590de34ddc62c540232e0
      with:
        ruby-version: 2.7.1
- name: Install PostgreSQL 12 client
      run: |
        sudo apt-get -yqq install libpq-dev
- name: Cache Ruby Gems
      uses: actions/cache@v2
      with:
        path: vendor/bundle
        key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
        restore-keys: |
          ${{ runner.os }}-gems-

    - name: Bundle Install
      run: |
        bundle config path vendor/bundle
        bundle install --jobs 4 --retry 3
- name: Run Tests
      env:
        PG_DATABASE: postgres
        PG_HOST: localhost
        PG_USER: postgres
        PG_PASSWORD: password
        RAILS_ENV: test
        WITH_COVERAGE: true
        DISABLE_SPRING: 1
      run: |
        bin/rails db:setup
        bundle exec rake rspec
