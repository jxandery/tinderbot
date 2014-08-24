require 'spec_helper'

describe Tinderbot::Tinder::Client do
  let(:tinder_client) { Tinderbot::Tinder::Client.new }
  let(:connection) { tinder_client.connection }

  describe '.connection' do
    it { expect(connection).to be_a(Faraday::Connection) }
    it { expect("#{connection.url_prefix.scheme}://#{connection.url_prefix.host}").to eq(Tinderbot::Tinder::Client::TINDER_API_URL) }
    it { expect(connection.headers[:user_agent]).to eq(Tinderbot::Tinder::Client::CONNECTION_USER_AGENT) }
  end

  describe '.me' do
    let(:user_response) { open('spec/fixtures/recommended_users.json').read }

    before { expect(connection).to receive(:get).with('profile').and_return(connection) }
    before { expect(connection).to receive(:body).and_return(user_response) }

    subject { tinder_client.me }

    it { should eq JSON.parse(user_response) }
  end

  describe '.user' do
    let(:user_id) { 'user_id' }
    let(:user_response) { open('spec/fixtures/user.json').read }

    before { expect(connection).to receive(:get).with("user/#{user_id}").and_return(connection) }
    before { expect(connection).to receive(:body).and_return(user_response) }

    subject { tinder_client.user user_id }

    it { should eq JSON.parse(user_response) }
  end

  describe '.updates' do
    let(:updates_response) { open('spec/fixtures/updates.json').read }

    before { expect(connection).to receive(:get).with('updates').and_return(connection) }
    before { expect(connection).to receive(:body).and_return(updates_response) }

    subject { tinder_client.updates }

    it { should eq JSON.parse(updates_response) }
  end

  describe '.recommended_users' do
    let(:recommended_people_response) { open('spec/fixtures/recommended_users.json').read }

    before { expect(connection).to receive(:post).with('user/recs').and_return(connection) }
    before { expect(connection).to receive(:body).and_return(recommended_people_response) }

    subject { tinder_client.recommended_users }

    it { should eq JSON.parse(recommended_people_response)['results'] }
  end

  describe '.like' do
    let(:user_id) { 'user_id' }

    before { expect(connection).to receive(:get).with("like/#{user_id}") }

    it { tinder_client.like user_id }
  end

  describe '.like_all' do
    context 'there is no people' do
      let(:people_ids) { [] }

      before { expect_any_instance_of(Tinderbot::Tinder::Client).not_to receive(:like) }

      it { tinder_client.like_all people_ids }
    end

    context 'there two people' do
      let(:people_ids) { %w(user_1_id user_2_id) }

      before { people_ids.each { |user_id| expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:like).with(user_id) } }

      it { tinder_client.like_all people_ids }
    end
  end

  describe '.dislike' do
    let(:user_id) { 'user_id' }

    before { expect(connection).to receive(:get).with("pass/#{user_id}") }

    it { tinder_client.dislike user_id }
  end

  describe '.dislike_all' do
    context 'there is no people' do
      let(:people_ids) { [] }

      before { expect_any_instance_of(Tinderbot::Tinder::Client).not_to receive(:dislike) }

      it { tinder_client.dislike_all people_ids }
    end

    context 'there two people' do
      let(:people_ids) { %w(user_1_id user_2_id) }

      before { people_ids.each { |user_id| expect_any_instance_of(Tinderbot::Tinder::Client).to receive(:dislike).with(user_id) } }

      it { tinder_client.dislike_all people_ids }
    end
  end

  describe '.send_message' do
    let(:user_id) { 'user_id' }
    let(:message) { 'message' }

    before { expect(connection).to receive(:post).with("user/matches/#{user_id}", {message: message}) }

    it { tinder_client.send_message user_id, message }
  end
end