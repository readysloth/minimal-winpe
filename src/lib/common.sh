cp_tree() {
  prefix="$1"
  from="$2"
  to="$3"
  resulting_path="$(echo "$to/$(dirname "$from")" | sed "s@$prefix@@g")"

  echo "$from -> $resulting_path" >> /tmp/cp_tree.log
  mkdir -p "$resulting_path" && cp -vr "$from" "$resulting_path"
}
