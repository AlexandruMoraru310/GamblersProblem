using Plots


number_of_plots = 5

p_head = 0.4

moves = [collect(1:min(s, 100-s)) for s in 1:99]
values = zeros(99)
policy = ones(Int64, 99)
values_to_display = Array{Float64}(undef, 99, number_of_plots)


# Get the value function of the optimal policy.

gamma = 1.0
epsilon = 10^(-16)
theta = 10^(-15)

counter = 1

delta = 1
while delta > theta
    global delta = 0
    for s in 1:99
        v = values[s]
        for a in moves[s]
            if s == 50
                if a == 50
                    current_value = p_head
                else
                    current_value = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
                end
            elseif s < 50
                if a == s
                    current_value = p_head * gamma * values[s+a]
                else
                    current_value = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
                end
            else
                if s + a == 100
                    current_value = p_head + (1.0 - p_head) * gamma * values[s-a]
                else
                    current_value = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
                end
            end
            if current_value > values[s]
                values[s] = current_value
            end
            global delta = max(delta, abs(v - values[s]))
        end
    end
    if counter <= number_of_plots - 1
        values_to_display[:, counter] .= values
        global counter = counter + 1
    end
end

values_to_display[:, end] .= values


# Get the optimal policy

for s in 1:99
    global max_value = -1
    for a in moves[s]
        if s == 50
            if a == 50
                current_value = p_head
            else
                current_value = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
            end
        elseif s < 50
            if a == s
                current_value = p_head * gamma * values[s+a]
            else
                current_value = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
            end
        else
            if s + a == 100
                current_value = p_head + (1.0 - p_head) * gamma * values[s-a]
            else
                current_value = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
            end
        end
        if current_value > max_value + epsilon
            global max_value = current_value
            policy[s] = a
        end
    end
end


# Plot optimal policy and corresponding value function

values_to_display[:, 1] .= values

gr()
Plots.plot(1:99, policy, xlims=(0, 100), ylims=(0, 60), xlabel="Capital", ylabel="Policy", seriestype=:stepmid, legend=false, size=(600, 250))
savefig("policy.png")

Plots.plot(values_to_display, xlims=(0, 100), ylims=(0, 1.1), xlabel="Capital", ylabel="Value estimates", seriestype=:line, label=["Sweep 1" "Sweep 2" "Sweep 3" "Sweep 4" "Last Sweep"], lw=2, size=(600, 500))
savefig("values.png")
