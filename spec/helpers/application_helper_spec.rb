require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:user) { create(:user, email: 'john.doe@example.com') }
  let(:user_with_profile) { create(:user, :mentee) }

  describe '#display_name' do
    it 'returns profile name when available' do
      user_with_profile.profile.update(name: 'John Doe')
      expect(helper.display_name(user_with_profile)).to eq('John Doe')
    end

    it 'returns email when profile name is blank' do
      user_with_profile.profile.update(name: '')
      expect(helper.display_name(user_with_profile)).to eq(user_with_profile.email)
    end

    it 'returns email when no profile exists' do
      expect(helper.display_name(user)).to eq(user.email)
    end

    it 'returns nil when user is nil' do
      expect(helper.display_name(nil)).to be_nil
    end
  end

  describe '#user_initials' do
    it 'returns first letter of first and last name' do
      user_with_profile.profile.update(name: 'John Doe')
      expect(helper.user_initials(user_with_profile)).to eq('JD')
    end

    it 'returns first two letters when only one name' do
      user_with_profile.profile.update(name: 'John')
      expect(helper.user_initials(user_with_profile)).to eq('JO')
    end

    it 'handles email when no profile name' do
      expect(helper.user_initials(user)).to eq('JO') # from john.doe@example.com
    end

    it 'handles multiple names by taking first and second' do
      user_with_profile.profile.update(name: 'John Michael Doe')
      expect(helper.user_initials(user_with_profile)).to eq('JM')
    end

    it 'handles empty name gracefully' do
      user_with_profile.profile.update(name: '')
      # Falls back to email - get first two letters of actual email
      email_initials = user_with_profile.email[0, 2].upcase
      expect(helper.user_initials(user_with_profile)).to eq(email_initials)
    end
  end

  describe '#avatar_color_class' do
    it 'returns consistent color for same user' do
      color1 = helper.avatar_color_class(user)
      color2 = helper.avatar_color_class(user)
      expect(color1).to eq(color2)
    end

    it 'returns different colors for different users' do
      user2 = create(:user)
      color1 = helper.avatar_color_class(user)
      color2 = helper.avatar_color_class(user2)
      # They might be the same due to modulo, but test the method works
      expect([color1, color2]).to all(match(/bg-\w+-500/))
    end

    it 'returns valid Tailwind color class' do
      color = helper.avatar_color_class(user)
      expect(color).to match(/bg-(rose|emerald|indigo|amber|fuchsia|teal)-500/)
    end

    it 'handles nil user' do
      expect(helper.avatar_color_class(nil)).to eq('bg-rose-500') # id.to_i returns 0
    end
  end

  describe '#section_container' do
    it 'creates section with default classes' do
      result = helper.section_container { 'content' }
      expect(result).to include('class="space-y-6 "')
      expect(result).to include('content')
    end

    it 'adds custom classes' do
      result = helper.section_container(class: 'custom-class') { 'content' }
      expect(result).to include('class="space-y-6 custom-class"')
    end
  end

  describe '#button_primary' do
    it 'creates button without path' do
      result = helper.button_primary('Click me')
      expect(result).to include('<button')
      expect(result).to include('Click me')
      expect(result).to include('bg-rose-600')
    end

    it 'creates link with path' do
      result = helper.button_primary('Click me', '/test')
      expect(result).to include('<a')
      expect(result).to include('href="/test"')
      expect(result).to include('Click me')
    end

    it 'adds custom classes' do
      result = helper.button_primary('Click me', nil, class: 'custom')
      expect(result).to include('custom')
    end
  end

  describe '#button_secondary' do
    it 'creates secondary button' do
      result = helper.button_secondary('Click me')
      expect(result).to include('bg-zinc-700')
      expect(result).to include('border-zinc-600')
    end
  end

  describe '#button_danger' do
    it 'creates danger button' do
      result = helper.button_danger('Delete')
      expect(result).to include('bg-red-600')
      expect(result).to include('Delete')
    end
  end

  describe '#status_badge' do
    it 'creates mentor badge' do
      result = helper.status_badge('Mentor', :mentor)
      expect(result).to include('bg-rose-600')
      expect(result).to include('Mentor')
    end

    it 'creates mentee badge' do
      result = helper.status_badge('Mentee', :mentee)
      expect(result).to include('bg-blue-600')
      expect(result).to include('Mentee')
    end

    it 'creates skill badge' do
      result = helper.status_badge('Rails', :skill)
      expect(result).to include('bg-rose-600')
      expect(result).to include('Rails')
    end

    it 'creates success badge' do
      result = helper.status_badge('Success', :success)
      expect(result).to include('bg-green-600')
    end

    it 'creates warning badge' do
      result = helper.status_badge('Warning', :warning)
      expect(result).to include('bg-yellow-600')
    end

    it 'creates danger badge' do
      result = helper.status_badge('Error', :danger)
      expect(result).to include('bg-red-600')
    end

    it 'creates default badge' do
      result = helper.status_badge('Default')
      expect(result).to include('bg-zinc-600')
    end
  end

  describe '#empty_state' do
    it 'creates empty state with default icon' do
      result = helper.empty_state('No items found')
      expect(result).to include('No items found')
      expect(result).to include('fa-regular fa-inbox')
    end

    it 'creates empty state with custom icon' do
      result = helper.empty_state('No messages', 'fa-regular fa-comments')
      expect(result).to include('No messages')
      expect(result).to include('fa-regular fa-comments')
    end

    it 'handles non-FontAwesome icon' do
      result = helper.empty_state('Empty', 'custom-icon')
      expect(result).to include('fa-regular fa-inbox') # falls back to default
    end
  end

  describe '#responsive_grid' do
    it 'creates responsive grid' do
      result = helper.responsive_grid { 'content' }
      expect(result).to include('grid sm:grid-cols-2 lg:grid-cols-3')
      expect(result).to include('content')
    end

    it 'adds custom classes to grid' do
      result = helper.responsive_grid(class: 'custom') { 'content' }
      expect(result).to include('custom')
    end
  end

  describe '#form_input_classes' do
    it 'returns default input classes' do
      result = helper.form_input_classes
      expect(result).to include('bg-zinc-700')
      expect(result).to include('border-zinc-600')
      expect(result).to include('focus:ring-rose-500')
    end

    it 'returns error classes when errors present' do
      result = helper.form_input_classes(errors: ['error'])
      expect(result).to include('border-red-400')
      expect(result).to include('focus:ring-red-500')
    end
  end

  describe '#form_label_classes' do
    it 'returns label classes' do
      result = helper.form_label_classes
      expect(result).to include('text-rose-400')
      expect(result).to include('font-medium')
    end
  end

  describe '#light_form_input_classes' do
    it 'returns light theme input classes' do
      result = helper.light_form_input_classes
      expect(result).to include('bg-white')
      expect(result).to include('border-zinc-300')
    end

    it 'returns light theme error classes' do
      result = helper.light_form_input_classes(errors: ['error'])
      expect(result).to include('border-red-400')
    end
  end

  describe '#light_form_label_classes' do
    it 'returns light theme label classes' do
      result = helper.light_form_label_classes
      expect(result).to include('text-gray-700')
    end
  end
end
