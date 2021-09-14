import re

def mark(text, args, Mark, extra_cli_args, *a):
    # This function is responsible for finding all
    # matching text. extra_cli_args are any extra arguments
    # passed on the command line when invoking the kitten.
    # We mark all individual word for potential selection
    for idx, m in enumerate(re.finditer(r'0x[0-9A-Fa-f]+', text)):
        start, end = m.span()
        mark_text = text[start:end].replace('\n', '').replace('\0', '')
        # The empty dictionary below will be available as groupdicts
        # in handle_result() and can contain arbitrary data.
        yield Mark(idx, start, end, mark_text, {})
