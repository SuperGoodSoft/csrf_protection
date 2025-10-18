# SuperGood::CSRFProtection

This Rack middleware provides CSRF protection using the Sec-Fetch-Site header. It is inspired by Go's `http.CrossOriginProtection` which was introduced in Go 1.25. You can read about it [in this article](https://www.alexedwards.net/blog/preventing-csrf-in-go) and find more information about the `Sec-Fetch-Site` header [on MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Sec-Fetch-Site).

The middleware blocks cross-origin state-changing requests (POST, PUT, PATCH, DELETE) by first checking the `Sec-Fetch-Site` header, which is available in all modern browsers, and rejecting requests where the value is not `same-origin` or `none`. For older browsers that don't send `Sec-Fetch-Site`, it falls back to comparing the `Origin` header against the `Host` header, ensuring that only requests from the same origin can modify state. Safe methods (GET, HEAD, OPTIONS) are always allowed through, and requests without an `Origin` header are treated as same-origin to support non-browser clients.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "super_good-csrf_protection"
```

And then execute:

```bash
bundle install
```

Or install it yourself with:

```bash
gem install super_good-csrf_protection
```

## Usage

Add the middleware to your Rack application:

```ruby
require "super_good/csrf_protection"

use SuperGood::CSRFProtection
```

The middleware rejects all non-GET requests without the `Sec-Fetch-Site: same-origin` header, providing protection against CSRF attacks.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SuperGoodSoft/csrf_protection. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/SuperGoodSoft/csrf_protection/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SuperGood::CSRFProtection project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/SuperGoodSoft/csrf_protection/blob/main/CODE_OF_CONDUCT.md).
