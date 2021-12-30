type right_t = Int.t
let null_right : right_t = Int.zero

type subject_t = string
type object_t = string

type state_r = {
	subj: subject_t list;
	obj: object_t list;
	rights: (subject_t * object_t, right_t) Hashtbl.t
	}

type condition_t =
	Top
	| Basic_condition of right_t * subject_t * object_t
	| And of condition_t * condition_t
	| Or of condition_t * condition_t
	| Neg of condition_t

type operation_t =
	Enter of right_t * subject_t * object_t
	| Delete of right_t * subject_t * object_t
	| Create_subject of subject_t
	| Destroy_subject of subject_t
	| Create_object of object_t
	| Destroy_object of object_t
type command_t = condition_t * (operation_t list)



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
				let new_rights = Hashtbl.copy st.rights in
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
				let new_rights = Hashtbl.copy st.rights in
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



let checkRight (st: state_r)
	(r: right_t) (s: subject_t) (o : object_t) : bool =
	match Hashtbl.find_opt st.rights (s, o) with
	| None -> false
	| Some a -> (Int.logand r a) > 0



let rec check_condition (st: state_r) (condition: condition_t) : bool =
	match condition with
	| Basic_condition (r, s, o) -> checkRight st r s o
	| And (c, c') -> (check_condition st c) && (check_condition st c')
	| Or (c, c') -> (check_condition st c) || (check_condition st c')
	| Top -> true
	| Neg c -> not (check_condition st c)

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
	let condition, _ = cmd in
	if check_condition st condition then
		let _, ops = cmd in
		List.fold_left
			(fun old_st op -> execute_operation old_st op)
			st ops
	else st

let rec path_finder (st: state_r) (available_commands: command_t list)
	(test: state_r -> bool) (limit: int) : command_t list option =
	if limit < 0 then None else
	if test st then Some [] else
	List.fold_left
		(fun path command ->
			try
				let st' = execute_command st command in
				match path_finder st' available_commands test (limit - 1) with
				| None -> path
				| Some p -> Some (List.append [command] p)
			with _ ->
				path
			)
		None
		available_commands
