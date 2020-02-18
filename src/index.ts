import parser from './parser';

export function parse(src: string) {
  try {
    return parser.parse(src);
  } catch (err) {
    if (err.location && err.location.start)
      err.message = `Line: ${err.location.start.line},${err.location.start.column}\n\n${err.message}`;
    else {
      console.log(err);
    }
    throw err;
  }
}
