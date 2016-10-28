class User
  attr_accessor :username

  def initialize(username)
    @username = username
  end

  # When choosing a GitHub username, the following validation applies:
  # "Login may only contain alphanumeric characters or single hyphens"
  # This validation isn't as robust as it could be, however prevents issues
  # whereby we could be making requests to the GitHub API with a mangled URI.
  def valid?
    (username =~ /\A[A-Za-z0-9\-]+\z/) != nil
  end

  def validate!
    raise UsernameValidationError, 'Invalid username' unless valid?
  end

  def languages
    validate!
    @languages ||= retrieve_languages
  end

  def exists?
    !languages.nil?
  end

  def repos?
    languages.count > 0
  end

  def favourite_language_determinable?
    grouped_languages.map(&:count).uniq.count > 1 || grouped_languages.count == 1
  end

  def favourite_language
    raise NoRepositoriesError unless repos?
    raise UndeterminableFavouriteLanguageError unless favourite_language_determinable?

    grouped_languages.max_by(&:count).first
  end

  private

  def grouped_languages
    languages.group_by(&:itself).values
  end

  def retrieve_languages
    response = HTTParty.get("https://api.github.com/users/#{username}/repos")
    response.parsed_response.map { |r| r['language'] }.compact if response.code == 200
  end
end

class UsernameValidationError < StandardError; end
class NoRepositoriesError < StandardError; end
class UndeterminableFavouriteLanguageError < StandardError; end
