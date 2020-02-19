import { toMatchFile } from 'jest-file-snapshot';

expect.extend({ toMatchFile });

// @ts-ignore
// eslint-disable-next-line no-underscore-dangle
global.__DEV__ = true;
