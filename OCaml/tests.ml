open HRU

let subject_1 : subject_t = "subject 1" and subject_2 : subject_t = "subject 2"
and subject_3 : subject_t = "subject 3" and subject_4 : subject_t = "subject 4"
and object_1 : object_t = "object 1" and object_2 : object_t = "object 2"
and object_3 : object_t = "object 3" and object_4 : object_t = "object 4"

let st_ini = { obj = [object_1]; subj = [subject_1; subject_2]; rights = Hashtbl.create 1000 }

let test_rights () : bool =
	let st_1_1_1 = execute_operation st_ini (Enter (1, subject_1, object_1)) in
	let st_2_1_1 = execute_operation st_1_1_1 (Enter (2, subject_1, object_1)) in
	let st_2_1_1' = execute_operation st_2_1_1 (Delete (2, subject_1, object_1)) in
	if checkRight st_ini 1 object_1 subject_1 = true then
		(Format.printf "st_ini has a right."; false)
	else
	if checkRight st_1_1_1 1 subject_1 object_1 = false then
		(Format.printf "1 ∉ (subject_1, object_1) (st_1_1_1)\n"; false)
		else
	if checkRight st_2_1_1 2 subject_1 object_1 = false then
		(Format.printf "2 ∉ (object_1, subject_1) (st_2_1_1)\n"; false)
	else
	if checkRight st_2_1_1 1 subject_1 object_1 = false then
		(Format.printf "1 ∉ (object_1, subject_1) (st_2_1_1)\n"; false)
	else
	if checkRight st_2_1_1' 2 subject_1 object_1 = true then
		(Format.printf "2 ∈ (object_1, subject_1) (st_2_1_1')\n"; false)
	else
	if checkRight st_2_1_1' 1 subject_1 object_1 = false then
		(Format.printf "1 ∉ (object_1, subject_1) (st_2_1_1')\n"; false)
	else
		true

let test_conditions () : bool =
	let st_1_1_1 = execute_operation st_ini (Enter (1, subject_1, object_1)) in
	let st_2_1_1 = execute_operation st_1_1_1 (Enter (2, subject_1, object_1)) in
	let st_2_1_1' = execute_operation st_2_1_1 (Delete (2, subject_1, object_1)) in
	(* I use the consitions that are checked in the previous test. *)
	let c_ini_false = Basic_condition(1, object_1, subject_1)
	and c_1_1_1_true = Basic_condition(1, subject_1, object_1)
	and c_1_1_1_false = Basic_condition(2, subject_1, object_1)
	and c_2_1_1_true = And(Basic_condition(2, subject_1, object_1), Basic_condition(1, subject_1, object_1))
	and c_2_1_1'_true = Or(Basic_condition(2, subject_1, object_1), Basic_condition(1, subject_1, object_1))
	and c_2_1_1'_false = And(Basic_condition(2, subject_1, object_1), Basic_condition(1, subject_1, object_1))
	in
	List.fold_left
		(fun v (c, st, goal) ->
			if check_condition st c = goal then
				v
			else
				false)
		true
		[c_ini_false, st_ini, false;
			c_1_1_1_true, st_1_1_1, true;
			c_1_1_1_false, st_1_1_1, false;
			c_2_1_1_true, st_2_1_1, true;
			c_2_1_1'_true, st_2_1_1', true;
			c_2_1_1'_false, st_2_1_1', false]



let test_path () : bool =
	(** Etat initial. *)
	let st_ini = { obj = []; subj = []; rights = Hashtbl.create 1000 } in

	(** Définition, des commandes sur lesquelles chercher *)
	let alpha : command_t = (Top, [Enter (1, "s", "o")])
	and beta : command_t = (Top, [Create_subject "s"])
	and gamma : command_t = (Top, [Create_object "o"])
	and delta : command_t = (Basic_condition(2, "s", "o"), [Delete (1, "s", "o")])
	and zeta : command_t = (Basic_condition(2, "s", "o"), [Delete (2, "s", "o")])
	and xi : command_t = (Basic_condition(1, "s", "o"), [Enter (2, "s", "o")])
	in

	(** Définition de l'objectif. *)
	let test_1 =
		(fun st -> (checkRight st 1 "s" "o"))
	and test_1_n2 =
		(fun st -> (checkRight st  1 "s" "o")
			&& not (checkRight st 2 "s" "o"))
	and test_2_1 =
		(fun st -> (checkRight st  2 "s" "o")
			&& (checkRight st 1 "s" "o"))
	and test_2_n1 =
		(fun st -> (checkRight st  2 "s" "o")
			&& not (checkRight st 1 "s" "o")) in

	(** Recherche bornée en longueur. *)
	List.fold_left
		(fun v (test, length, goal) ->
			match path_finder st_ini [alpha; beta ; gamma ; delta ; zeta ; xi]
				test length, goal with
			| None, false -> v
			| Some _, true -> v
			| None, true -> false
			| Some _, false -> false)
			true
			[
				test_1, 1, false;
				test_1_n2, 1, false;
				test_2_1, 1, false;
				test_2_n1, 1, false;
				test_1, 3, true;
				test_1_n2, 3, true;
				test_2_1, 4, true;
				test_2_n1, 5, true;
				test_2_n1, 2, false;
				test_2_n1, 3, false;
				test_2_n1, 4, false]



let test () =
	Format.printf "Starting tests:\n";
	if List.fold_left
		(fun v (s, f) ->
			if f () then
				(Format.printf "\x1b[032m[%30s] Passed\x1b[0m\n" s ; v)
			else
				(Format.printf "\x1b[031m[%30s] Not passed\x1b[0m\n" s; false))
		true
		["Checking the rights check", test_rights ;
			"Checking the conditions", test_conditions;
			"Search the paths", test_path]
		then
		Format.printf "End of tests: Ok.\n\n"
		else
		Format.printf "End of tests: Not ok!\n\n";

