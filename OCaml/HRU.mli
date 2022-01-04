type right_t = Int.t
val null_right : right_t
type subject_t = string
type object_t = string
type state_r = {
  subj : subject_t list;
  obj : object_t list;
  rights : (subject_t * object_t, right_t) Hashtbl.t;
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
val execute_operation : state_r -> operation_t -> state_r
val checkRight : state_r -> right_t -> subject_t -> object_t -> bool
val check_condition : state_r -> condition_t -> bool
val test_equal : state_r -> state_r -> bool
val execute_command : state_r -> command_t -> state_r
val path_finder : state_r -> command_t list -> (state_r -> bool) ->int -> command_t list option
