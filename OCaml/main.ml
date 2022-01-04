open HRU

let pp (st: state_r) : unit =
	Format.printf "\nSubjects:" ;
	List.iter (fun s -> Format.printf "\n\t→ '%s'" s) st.subj;
	Format.printf "\nObjects:" ;
	List.iter (fun s -> Format.printf "\n\t→ '%s'" s) st.obj;
	Format.printf "\nRights:" ;
	Hashtbl.iter
		(fun (s, o) r -> Format.printf "\n\t→ %d ∈ ('%s', '%s')" r s o) st.rights;
	Format.printf "\n\n"



let launch_pileup () =
	(** Definition of subjects *)
	let application : subject_t = "application"
	and app_manager : subject_t = "application manager"
	and perm_manager : subject_t = "permission manager"
	(** Definition of objects *)
	and permission : object_t = "Permission"
	and application_obj : object_t = "Application (obj)"
	(** Définition des droits *)
	and has: right_t = 1 and exists : right_t = 2 and authorized : right_t = 4
	and meaningful : right_t = 8 in
	
	(** État initial *)
	let st_initial : state_r = {
		subj = [application ; app_manager ; perm_manager] ;
		obj = [permission ; application_obj] ;
		rights = Hashtbl.create 1000
	}

	(** Définition des commandes *)
	and install_1 : command_t =
		(And(
			Neg(Basic_condition(exists, app_manager, application_obj)),
			Basic_condition(exists, perm_manager, permission)),
		[Enter(authorized, application, permission) ;
			Enter(has, application, permission) ;
			Enter(exists, app_manager, application_obj)])
	and install_0 : command_t =
		(And(
			Neg(Basic_condition(exists, app_manager, application_obj)),
			Neg(Basic_condition(exists, perm_manager, permission))),
		[Enter(has, application, permission) ;
			Enter(exists, app_manager, application_obj) ;
			Enter(exists, perm_manager, permission)])
	and maj_0 : command_t =
		(Neg(Basic_condition(exists, perm_manager, permission)),
		[Enter(exists, perm_manager, permission) ;
			Enter(meaningful, perm_manager, permission)])
	and maj_1 : command_t =
		(Basic_condition(exists, perm_manager, permission),
		[Enter(meaningful, perm_manager, permission)]) in
	
	(** Définition de l'élévation de privilèges *)
	let goal (st : state_r) : bool =
		check_condition st
			(And(
				Basic_condition(exists, app_manager, application_obj),
				And(
					Basic_condition(exists, perm_manager, permission),
					And(
						Basic_condition(has, application, permission),
						Basic_condition(meaningful, perm_manager, permission)))))
		in
	
	(** Recherche d'un chemin *)
	let path = path_finder st_initial
		[install_0 ; install_1 ; maj_0 ; maj_1 ] goal 10 in
	match path with
	| None -> Format.printf "Blah blah blah\n"
	| Some _ -> Format.printf "Hey, found one !\n"



let _ =
	(** Launching the tests 
	Tests.test (); *)

	(** Test to find a path for the Pileup problem *)
	launch_pileup ()
