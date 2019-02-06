# Helper to handle a promotion
# The name 'January Promotion' is an example, could be 'Buen Fin Promotion', 'Christmas Promotion', etc.
module JanuaryPromotionHelper
    # Helper to get the table data.
    def january_promotion_table(user)
        promotion = Promotion.new(user)
        return promotion.get_table
    end

    # Class that handle the promotion logic
    class Promotion
        @@default_sd = {
            :ranges => [0, 10000, 25000.01, 50000.01],
            :data => [1323.26167300775, 5839.5063730629, 10550.1895717565, 19266.2053001276]
        }
        # The table with the posibles bonuses
        @@bonuses_tables = {
            :ranges => [0, 0.3, 1.3],
            :data => [
                { # cv < 0.3
                    :ranges => [0, 10000, 25000.01, 50000.01],
                    :data => [
                        [ # average < $10'000.00
                            { :sd => 0.8, :bonus => 20 }, { :sd => 2.4, :bonus => 30 }, { :sd => 7.2, :bonus => 35 }
                        ],
                        [ # $10'000.00 <= average < $25'000.01
                            { :sd => 0.8, :bonus => 25 }, { :sd => 2.4, :bonus => 30 }, { :sd => 7.2, :bonus => 35 }
                        ],
                        [ # $25'000.01 <= average < $50'000.01
                            { :sd => 0.8, :bonus => 25 }, { :sd => 2.4, :bonus => 30 }, { :sd => 7.2, :bonus => 35 }
                        ],
                        [ # average > $50'000.00
                            { :sd => 1.3, :bonus => 25 }, { :sd => 3.9, :bonus => 30 }, { :sd => 11.7, :bonus => 40 }
                        ]
                    ]
                },
                { # 1.3 > cv >= 0.3
                    :ranges => [0, 10000, 25000.01, 50000.01],
                    :data => [
                        [ # average < $10'000.00
                            { :sd => 0.35, :bonus => 30 }, { :sd => 0.7, :bonus => 35 }, { :sd => 3.5, :bonus => 40 }
                        ],
                        [ # $10'000.00 <= average < $25'000.00
                            { :sd => 0.25, :bonus => 20 }, { :sd => 0.5, :bonus => 30 }, { :sd => 2.5, :bonus => 35 }
                        ],
                        [ # $25'000.01 <= average < $50'000.01
                            { :sd => 0.2, :bonus => 20 }, { :sd => 0.4, :bonus => 30 }, { :sd => 1.6, :bonus => 40 }
                        ],
                        [ # average > $50'000.00
                            { :sd => 0.5, :bonus => 20 }, { :sd => 1, :bonus => 30 }, { :sd => 4, :bonus => 35 }
                        ]
                    ]
                },
                { # cv >= 1.3
                    :ranges => [0, 40000],
                    :data => [
                        [ # average < $40'000.00
                            { :sd => 0.35, :bonus => 30 }, { :sd => 0.7, :bonus => 35 }, { :sd => 3.5, :bonus => 40 }
                        ],
                        [ # average >= $40'000.00
                            { :sd => 0.25, :bonus => 20 }, { :sd => 0.5, :bonus => 30 }, { :sd => 2.5, :bonus => 35 }
                        ]
                    ]
                }
            ]
        }

        # We need the user to get investments
        def initialize(user)
            @user = user
        end

        # Get the table of possibles bonuses
        def get_table
            return build_data
        end

        private
            def build_data
                # The investments to consider
                investments = get_investments

                # Calculations
                average = get_investments_average(investments)
                stdv = get_standard_deviation(investments, average)
                cv = stdv / average
                if cv <= 0.14
                    # If the cv is less than 0.14, we use a default sd
                    stdv = get_item_from_range(average, @@default_sd)
                end

                # The bonuses to use
                table = get_bonuses_table(investments, cv)
                bonuses = get_bonuses(table, average)

                # Build the data
                data = bonuses.enum_for(:each_with_index).map do |bonus, index|
                    row = { :lower_limit => bonus[:sd] * stdv, :bonus => bonus[:bonus] }
                    # If there are a next bonus, calculate the upper limit
                    next_bonus = bonuses[index + 1]
                    if next_bonus != nil
                        row[:upper_limit] = next_bonus[:sd] * stdv - 0.01
                    end
                    row
                end
                return data
            end

            # The investments to consider are those that the amount without wallet amount is greater than 3000
            def get_investments
                investments = @user.investments.where('amount - wallet_amount > 3000').to_a

                if investments.empty?
                    # if there are not valid investment (or the users doesn't have investments), we use a single
                    # investment of $5'000.00 (without wallet amount), and the average is $5'000.00
                    investments = [
                        Investment.new({
                            :amount => 5000,
                            :wallet_amount => 0
                        })
                    ]
                end

                return investments
            end

            # Get the average of the amount without wallet amount of the user's investments.
            def get_investments_average(investments)
                return investments.sum{ |investment| investment.amount - investment.wallet_amount }.fdiv(investments.size)
            end

            # Calculate the standard deviation of the investments.
            def get_standard_deviation(investments, average)
                if investments.size == 1
                    # We use a default sd if there are only one investment.
                    return get_item_from_range(average, @@default_sd)
                end
                sum = investments.sum{
                    |investment| ((investment.amount - investment.wallet_amount) - average) ** 2
                }.fdiv(investments.size)
                return Math.sqrt(sum)
            end

            # Get the posible bonuses to use, using the average of investments to determine the bonuses to use.
            def get_bonuses(table, average)
                return get_item_from_range(average, table)
            end

            # Get the table of bonuses to use, using the cv to determine the table
            def get_bonuses_table(investments, cv)
                if investments.size == 1 || cv <= 0.14
                    # We use the table for cv 0.3 if there are only one investment.
                    # or if the cv is less than 0.14
                    cv = 0.3
                end
                return get_item_from_range(cv, @@bonuses_tables)
            end

            # Get an item from an array comparing a value with ranges to determine the item to return.
            # We need an object with the ranges and the data.
            def get_item_from_range(value, obj)
                index = get_index_for_range(value, obj[:ranges])
                return obj[:data][index]
            end

            # With an array of ranges, return the index of the range where the value is between
            def get_index_for_range(value, ranges)
                ranges.each_with_index do |range_start, index|
                    range_end = ranges[index + 1]

                    # If is the last item (when there are not a range_end), we are on the last item of the array, so the
                    # value should be greater than the last value.
                    # Or if the value is between the range_start and range_end.
                    if range_end == nil || (value >= range_start && value < range_end)
                        return index
                    end
                end
            end
    end
end
