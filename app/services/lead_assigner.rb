class LeadAssigner
  LEAD_CAPACITY = 10

  def self.call(lead_capacity: LEAD_CAPACITY)
    new(lead_capacity:).call
  end

  def call
    solver = ORTools::Solver.new("CBC")

    leads = Lead.all.order(:id).to_a
    users = User.includes(:industries).all.order(:id).to_a
    lead_count = leads.count
    user_count = users.count
    industries_count = Industry.all.count

    return if users.empty? || leads.empty?

    x = {}
    user_count.times do |i|
      lead_count.times do |j|
        x[[i, j]] = solver.bool_var("x[#{i},#{j}]")
      end
    end

    # Ensure that a lead can be assigned to only one person
    lead_count.times do |j|
      solver.add(user_count.times.sum { |i| x[[i, j]] } <= 1)
    end

    # Ensure that each sales person cannot exceed their capacity
    user_count.times do |i|
      solver.add(lead_count.times.sum { |j| x[[i, j]] } <= @lead_capacity)
    end

    # We optimise based on a score which says that they should be assigned
    # leads based on their industry speciality
    costs = Array.new(user_count) { Array.new(lead_count, -industries_count) }
    users.each_with_index do |user, i|
      industries = user.industries.pluck(:id).each_with_index.to_h
      leads.each_with_index do |lead, j|
        costs[i][j] = industries.length - industries[lead.industry_id] if industries[lead.industry_id]
      end
    end

    max_cost = industries_count
    min_cost = -industries_count
    cost_range = max_cost - min_cost

    # Use a bonus that's larger than any cost difference between assignments to
    # ensure we get a matching of maximum size
    assignment_bonus = cost_range + 1

    # create the objective which we maximise to obtain an optimal assignment of sales rep
    # to their preferred industry
    solver.minimize(
      user_count.times.flat_map { |i| lead_count.times.map { |j| x[[i, j]] * (-costs[i][j] - assignment_bonus) } }.sum
    )

    solver.solve

    Lead.transaction do
      Lead.update_all(user_id: nil)
      leads.each(&:reload)
      user_count.times do |i|
        lead_count.times do |j|
          leads[j].update(user: users[i]) if x[[i, j]].solution_value > 0
        end
      end
    end
  end

  private

  def initialize(lead_capacity:)
    @lead_capacity = lead_capacity
  end
end
