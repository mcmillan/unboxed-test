require_relative 'spec_helper'

RSpec.describe User do
  let(:valid_username) { 'mcmillan' }
  let!(:valid_user) { User.new(valid_username) }
  let!(:user_without_favourite) { User.new('octokit') }
  let!(:user_without_repos) { User.new('ubxd') }
  let!(:nonexistent_user) { User.new('this-user-does-not-exist') }
  let!(:invalid_user) { User.new('!!') }

  describe '#initialize' do
    it 'stores the provided username' do
      expect(valid_user.username).to eq(valid_username)
    end
  end

  describe '#valid?' do
    context 'with a valid username' do
      it 'returns true' do
        expect(valid_user.valid?).to eq(true)
      end
    end

    context 'with an invalid username' do
      it 'returns false' do
        expect(invalid_user.valid?).to eq(false)
      end
    end
  end

  describe '#validate!' do
    context 'with an invalid username' do
      it 'raises a UsernameValidationError' do
        expect { invalid_user.validate! }.to raise_error(UsernameValidationError)
      end
    end
  end

  describe '#languages', :vcr do
    context 'with a valid user' do
      it 'returns an array of programming languages' do
        aggregate_failures do
          expect(valid_user.languages).to be_an(Array)
          expect(valid_user.languages).to include('Ruby')
        end
      end
    end

    context 'with a nonexistent / invalid user' do
      it 'returns nil' do
        expect(nonexistent_user.languages).to eq(nil)
      end
    end
  end

  describe '#exists?', :vcr do
    context 'with a user that exists on GitHub' do
      it 'returns true' do
        expect(valid_user.exists?).to eq(true)
      end
    end

    context 'with a nonexistent user' do
      it 'returns false' do
        expect(nonexistent_user.exists?).to eq(false)
      end
    end
  end

  describe '#repos?', :vcr do
    context 'with a user with at least one repository' do
      it 'returns true' do
        expect(valid_user.repos?).to eq(true)
      end
    end

    context 'with a user with no repositories' do
      it 'returns false' do
        expect(user_without_repos.repos?).to eq(false)
      end
    end
  end

  describe '#favourite_language_determinable?', :vcr do
    context 'with a user with a language used more than any other' do
      it 'returns true' do
        expect(valid_user.favourite_language_determinable?).to eq(true)
      end
    end

    context 'with a user without a language used more than any other' do
      it 'returns false' do
        expect(user_without_favourite.favourite_language_determinable?).to eq(false)
      end
    end
  end

  describe '#favourite_language', :vcr do
    context 'with a user with a favourite language' do
      it 'returns their favourite language' do
        expect(valid_user.favourite_language).to eq('Ruby')
      end
    end

    context 'with a user with no determinable favourite language' do
      it 'raises a UndeterminableFavouriteLanguageError' do
        expect do
          user_without_favourite.favourite_language
        end.to raise_error(UndeterminableFavouriteLanguageError)
      end
    end

    context 'with a user with no repositories' do
      it 'raises a NoRepositoriesError' do
        expect do
          user_without_repos.favourite_language
        end.to raise_error(NoRepositoriesError)
      end
    end
  end
end
