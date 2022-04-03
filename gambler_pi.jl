using Plots


number_of_plots = 5

p_head = 0.4

moves = [collect(1:min(s, 100-s)) for s in 1:99]
values = collect(range(0.01, stop=0.5, length=99))
policy = [1 for s in 1:99]
values_to_display = Array{Float64}(undef, 99, number_of_plots)
gamma = 1.0

counter = 1

epsilon = 10^(-15)

# v(s) = E{G_t|S_t=s}
theta = 10^(-12)
policy_stable = false
while policy_stable == false
    # Policy Evaluation
    global delta = 1.0
    while delta > theta
        global delta = 0
        for s in 1:99
            v = values[s]
            if s == 50
                if policy[s] == 50
                    values[s] = p_head
                else
                    values[s] = p_head * gamma * values[s+policy[s]] + (1.0 - p_head) * gamma * values[s-policy[s]]
                end
            elseif s < 50
                if policy[s] == s
                    values[s] = p_head * gamma * values[s+policy[s]]
                else
                    values[s] = p_head * gamma * values[s+policy[s]] + (1.0 - p_head) * gamma * values[s-policy[s]]
                end
            else
                if s + policy[s] == 100
                    values[s] = p_head + (1.0 - p_head) * gamma * values[s-policy[s]]
                else
                    values[s] = p_head * gamma * values[s+policy[s]] + (1.0 - p_head) * gamma * values[s-policy[s]]
                end
            end
            global delta = max(delta, abs(v - values[s]))
        end
    end
    if counter <= number_of_plots - 1
        values_to_display[:, counter] .= values
        global counter = counter + 1
    end
    # Policy Improvement
    global policy_stable = true
    for s in 1:99
        old_action = policy[s]
        global maximum_goal = -1
        for a in moves[s]
            if s == 50
                if a == 50
                    current_goal = p_head
                else
                    current_goal = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
                end
            elseif s < 50
                if a == s
                    current_goal = p_head * gamma * values[s+a]
                else
                    current_goal = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
                end
            else
                if s + a == 100
                    current_goal = p_head + (1.0 - p_head) * gamma * values[s-a]
                else
                    current_goal = p_head * gamma * values[s+a] + (1.0 - p_head) * gamma * values[s-a]
                end
            end
            if current_goal > maximum_goal + epsilon
                global maximum_goal = current_goal
                policy[s] = a
            end
        end
        if old_action != policy[s]
            global policy_stable = false
        end
    end
end

values_to_display[:, end] .= values

gr()
Plots.plot(1:99, policy, xlims=(0, 100), ylims=(0, 60), xlabel="Capital", ylabel="Policy", seriestype=:stepmid, legend=false, size=(600, 250))
savefig("policy.png")

Plots.plot(values_to_display, xlims=(0, 100), ylims=(0, 1.1), xlabel="Capital", ylabel="Value estimates", seriestype=:line, label=["Sweep 1" "Sweep 2" "Sweep 3" "Sweep 4" "Last Sweep"], lw=2, size=(600, 500))
savefig("values.png")
