let _ =
  let root_dir = Sys.argv.(1) in
  let rec recurse dir_name installer_name =
    let h = Unix.opendir dir_name in
    let l = ref [] in
    while
      try begin
        let item = Unix.readdir h in
        if item <> "." && item <> ".." then begin
          let full_path = dir_name ^ "/" ^ item in
          let installer_name = installer_name ^ "\\" ^ item in
          let stats = Unix.stat full_path in
          if stats.Unix.st_kind = Unix.S_DIR then
            l := recurse full_path installer_name @ !l;
          l := (stats.Unix.st_kind, installer_name) :: !l;
        end;
        true
      end with End_of_file -> false
    do () done;
    !l
  in
  let items = recurse root_dir "$INSTDIR" in
  let get_install_line (_, name) =
    Printf.sprintf "File %s" name
  in
  let get_uninstall_line = function
    | (Unix.S_REG, name) ->
        Printf.sprintf "Delete \"%s\"" name
    | (Unix.S_DIR, name) ->
        Printf.sprintf "RMDir \"%s\"" name
  in
  (*let install_lines = List.map get_install_line items in
  let i_f = open_out "install_lines.nsi" in
  output_string i_f (String.concat "\n" install_lines);
  output_string i_f "\n";
  close_out i_f;*)
  let uninstall_lines = List.map get_uninstall_line (List.rev items) in
  let u_f = open_out "uninstall_lines.nsi" in
  output_string u_f (String.concat "\n" uninstall_lines);
  output_string u_f "\n";
  close_out u_f;
  ()
