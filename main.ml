(**		  +~~~~~~~~~~~~~~~~~~~~~~~~~~+
  *		  | Définition du modèle HRU |
  *		  +~~~~~~~~~~~~~~~~~~~~~~~~~~+
*)
type right = Int.t
let null_right : right = Int.zero

type subject_t = string
type object_t = string

type state_r = {
	subj: subject_t list;
	obj: object_t list;
	rights: (subject_t * object_t, right) Hashtbl.t
	}

type condition_t =
	Basic_condition of right * subject_t * object_t
	| And of condition_t * condition_t
	| Or of condition_t * condition_t
type operation_t =
	Enter of right * subject_t * object_t
	| Delete of right * subject_t * object_t
	| Create_subject of subject_t
	| Destroy_subject of subject_t
	| Create_object of object_t
	| Destroy_object of object_t
type command_t = string list * string list * condition_t * operation_t list



let execute_operation (st: state_r) (op: operation_t) : state_r =
	match op with
	| Enter (r, s, o) ->
		if not (List.mem s st.subj) then
			failwith "Unknown subject."
		else
			if not (List.mem o st.obj) then
			failwith "Unknown object."
			else
				(
				let old_right =
					match Hashtbl.find_opt st.rights (s, o) with
					| None -> null_right
					| Some i -> i
					in
				let new_rights = st.rights in
				Hashtbl.add new_rights (s, o) (Int.logor old_right r);
				{ subj = st.subj; obj = st.obj; rights = new_rights }
				)
	| Delete (r, s, o) ->
		if not (List.mem s st.subj) then
			failwith "Unknown subject."
		else
			if not (List.mem o st.obj) then
			failwith "Unknown object."
			else
				(
				let old_right =
					match Hashtbl.find_opt st.rights (s, o) with
					| None -> null_right
					| Some i -> i
					in
				let new_rights = st.rights in
				(** TODO *)
				if Int.logand old_right r > 0 then
					Hashtbl.add new_rights (s, o) (old_right - r);
				{ subj = st.subj; obj = st.obj; rights = new_rights }
				)
	| Create_subject s ->
		{subj = List.append st.subj [s]; obj = st.obj; rights = st.rights}
	| Destroy_subject s ->
		{subj = List.filter (fun s' -> s' = s) st.subj; obj = st.obj; rights = st.rights}
	| Create_object o ->
		{subj = st.subj; obj = List.append st.obj [o]; rights = st.rights}
	| Destroy_object o ->
		{subj = st.subj; obj = List.filter (fun o' -> o' = o) st.obj; rights = st.rights}



let rec check_condition (st: state_r) (condition: condition_t) : bool =
	match condition with
	| Basic_condition (r, s, o) ->
		(match Hashtbl.find_opt st.rights (s, o) with
		| None -> false
		| Some a -> (Int.logand r a) > 0
		)
	| And (c, c') -> (check_condition st c) && (check_condition st c')
	| Or (c, c') -> (check_condition st c) || (check_condition st c')

let test_equal (st : state_r) (st' : state_r) : bool =
	if
		(* Checks the subjects equality *)
		List.fold_left (fun v s -> (List.mem s st'.subj) && v) true st.subj
		&& List.fold_left (fun v s -> (List.mem s st.subj) && v) true st'.subj
		(* Checks the objects equality *)
		&& List.fold_left (fun v s -> (List.mem s st'.obj) && v) true st.obj
		&& List.fold_left (fun v s -> (List.mem s st.obj) && v) true st'.obj
		then
			List.fold_left
				(fun eq_val o ->
					List.fold_left
						(fun eq_val s ->
							eq_val && Hashtbl.find_opt st.rights (s, o) = Hashtbl.find_opt st'.rights (s, o)
						)
						eq_val
						st.subj
				)
				true
				st.obj
		else
			false

let execute_command (st: state_r) (cmd: command_t) : state_r =
	let _, _, condition, _ = cmd in
	if check_condition st condition then
		let _, _, _, ops = cmd in
		List.fold_left
			(fun old_st op -> execute_operation old_st op)
			st ops
	else st



(**		   +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
  *		   | Recherche par bruteforce avec backtracking |
  *		   +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
*)



let test () =
	(* Definition of some subjects *)
	let subject_1 : subject_t = "subject 1" and subject_2 : subject_t = "subject 2"
	and subject_3 : subject_t = "subject 3" and subject_4 : subject_t = "subject 4"
	(* Definition of some objects *)
	and object_1 : object_t = "object 1" and object_2 : object_t = "object 2"
	and object_3 : object_t = "object 3" and object_4 : object_t = "object 4"
	(* Definition of some operations *)
	and operation_1 : operation_t = Enter (1, "subject 1", "object 1")
	and operation_2 : operation_t = Delete (1, "subject 1", "object 1")
	in
	let condition_1 : condition_t = Basic_condition (1, "subject 1", "object 1")
	in
	(* TODO: finir le test *)
	()



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

