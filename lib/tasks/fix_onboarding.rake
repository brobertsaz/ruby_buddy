namespace :onboarding do
  desc "Mark users with role and profile/request as onboarding complete"
  task fix_stuck_users: :environment do
    # Find users who have a role and either a profile or mentorship request but onboarding not complete
    stuck_users = User.where(onboarding_completed: false).where.not(role: [nil, ''])
    
    stuck_users.each do |user|
      # If they have a profile (mentor) or mentorship request (mentee), mark complete
      if user.profile.present? || user.mentorship_requests.any?
        user.update(onboarding_completed: true)
        puts "✓ Marked user #{user.id} (#{user.email}) as onboarding complete"
      else
        puts "- User #{user.id} (#{user.email}) has role '#{user.role}' but no profile/request yet"
      end
    end
    
    puts "\nDone! Fixed #{stuck_users.count} users."
  end
end

