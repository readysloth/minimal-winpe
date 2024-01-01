cp_tree() {
  prefix="$1"
  from="$2"
  to="$3"
  callback="${4:-:}"
  resulting_path="$(echo "$to/$(dirname "$from")" | sed "s@$prefix@@g")"
  resulting_path="${resulting_path//$prefix/}"

  mkdir -p "$resulting_path" && cp -r "$from" "$resulting_path"
  $callback "$from" "$resulting_path"
}
