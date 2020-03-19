# EsignIdentity

易签宝身份认证 SDK

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'esign_identity'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install esign_identity

## Usage

```ruby
Esign.configure do |config|
  config.app_id = 'xxxxx'  
  config.app_secret = 'xxxx'  
  config.identity_host = 'xxxx'  
end

instance = Esign::Identity.instance

# 个人身份认证
instance.identify_individual(name, id_no, bank_card_number, phone_number)
  
# 企业身份认证
instance.identify_enterprise(name, social_code, legal_person_name)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/esign_identity.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
