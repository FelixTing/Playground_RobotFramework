import json
import jsonpointer


class Tools:

    def should_be_valid_json(self, json_string):
        try:
            return json.loads(json_string)
        except ValueError as e:
            raise ValueError("Could not parse '%s' as JSON: %s" % (json_string, e))

    def get_json_value(self, json_string, json_pointer):
        return jsonpointer.resolve_pointer(json_string, json_pointer)