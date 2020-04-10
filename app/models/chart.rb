# frozen_string_literal: true

class Chart
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def hour_line_chart_data
    data_hash = Unfollower.unscoped.where(user: user).group_by_hour_of_day(:created_at, format: '%-l %P', range: 1.day.ago.midnight..Time.current).count

    {
      labels: data_hash.keys,

      datasets: [
        {
          label: 'Hourly',
          backgroundColor: 'rgba(54, 162, 235, 0.2)',
          borderColor: 'rgba(54, 162, 235, 1)',
          data: data_hash.values
        }
      ]
    }
  end

  def week_line_chart_data
    data_hash = Unfollower.unscoped.where(user: user).group_by_week(:created_at, week_start: :monday, last: 3).count

    {
      labels: data_hash.keys,

      datasets: [
        {
          label: 'Weekly',
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderColor: 'rgba(255, 99, 132, 1)',
          data: data_hash.values
        }
      ]
    }
  end

  def month_line_chart_data
    data_hash = Unfollower.unscoped.where(user: user).group_by_month(:created_at, last: 3).count

    {
      labels: data_hash.keys,

      datasets: [
        {
          label: 'Monthly',
          backgroundColor: 'rgba(255, 206, 86, 0.2)',
          borderColor: 'rgba(255, 206, 86, 1)',
          data: data_hash.values
        }
      ]
    }
  end
end
