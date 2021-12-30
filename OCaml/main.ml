open HRU



let rec reach_failure (test: state_r -> bool)
	(current_path: command_t list option)
	(initial_state: state_r) (cmds: command_t list) : (command_t list) option =
	if test initial_state
		then current_path
	else
		List.fold_left
			(fun cur_path cmd ->
				match cur_path with
				| Some p -> cur_path
				| None ->
				(
					let new_state = execute_command initial_state cmd in
					if test_equal new_state initial_state then
						None
					else
						reach_failure test current_path new_state cmds
				)
			)
			current_path
			cmds


let _ =
	Tests.test ()
