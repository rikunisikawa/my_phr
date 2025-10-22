require "rails_helper"

RSpec.describe "Dashboard flow", type: :system do
  let(:user) { create(:user, email: "user@example.com", password: "password") }

  it "allows a signed-in user to view dashboard and navigate" do
    create(:health_log, user: user, recorded_at: Time.zone.now.change(sec: 0), mood: 3)

    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password"
    click_button "ログイン"

    expect(page).to have_content("ダッシュボード")
    expect(page).to have_link("健康ログ")

    click_link "健康ログ"
    expect(page).to have_content("健康ログ一覧")
  end
end
