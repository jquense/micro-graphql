import { parse } from '../src';
import path from 'path';

import fs from 'fs';

describe('parsing', () => {
  it('should parse', () => {
    const schema = fs.readFileSync(
      `${__dirname}/fixtures/kitchen-sink.graphql`,
      'utf8',
    );

    expect(() => parse(schema)).not.toThrow();
  });

  it('should parse github', () => {
    const schema = fs.readFileSync(
      `${__dirname}/fixtures/github-public.graphql`,
      'utf8',
    );

    expect(() => parse(schema)).not.toThrow();
  });

  it('should parse a complex execution document', () => {
    const schema = fs.readFileSync(
      `${__dirname}/fixtures/query.graphql`,
      'utf8',
    );

    //@ts-ignore
    expect(JSON.stringify(parse(schema), null, 2)).toMatchFile(
      path.join(__dirname, '__file_snapshots__/query-ast.json'),
    );
  });

  // it('should parse interface with directive', () => {
  //   parse(`

  //     extend interface Bar @onInterface

  //   `);
  // });
});
