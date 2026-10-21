'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const Ajv = require('ajv');

const root = path.resolve(__dirname, '..');
const ajv = new Ajv({ allErrors: true, strict: true, strictRequired: false });
const schemas = fs.readdirSync(path.join(root, 'schemas')).filter(name => name.endsWith('-v1.json'));
for (const name of schemas) {
  ajv.addSchema(JSON.parse(fs.readFileSync(path.join(root, 'schemas', name), 'utf8')));
}
const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'foundry-contracts-'));
try {
  const args = ['exec', 'ruby', '-Itest', '-Ilib', 'test/stable_contracts_test.rb'];
  console.log(`$ bundle ${args.join(' ')}`);
  const result = spawnSync('bundle', args, {
    cwd: root, stdio: 'inherit',
    env: { ...process.env, FOUNDRY_CONTRACT_SAMPLES: temporary }
  });
  if (result.error) throw result.error;
  assert.equal(result.status, 0, 'Ruby contract acceptance failed');
  let count = 0;
  for (const name of fs.readdirSync(temporary)) {
    const sample = JSON.parse(fs.readFileSync(path.join(temporary, name), 'utf8'));
    const validate = ajv.getSchema(`https://schemas.rails-ai-foundry.invalid/${sample.schema}-v1.json`);
    assert(validate, `Missing schema: ${sample.schema}`);
    assert.equal(validate(sample.data), sample.valid, `${name}: ${JSON.stringify(validate.errors)}`);
    if (sample.data.report_schema) {
      assert.equal(validate({ ...sample.data, report_schema: 2 }), false, 'Future reports must fail validation');
      const missing = { ...sample.data };
      delete missing.foundry_version;
      assert.equal(validate(missing), false, 'Producer identity is required');
      assert.equal(validate({ ...sample.data, future_additive_field: true }), true, 'Readers must permit additions');
    }
    count += 1;
  }
  assert(count >= 60, `Missing configuration/report samples: ${count}`);
  for (const name of schemas) {
    assert(ajv.getSchema(`https://schemas.rails-ai-foundry.invalid/${name}`));
  }
  console.log(`Validated ${schemas.length} schema assets and ${count} actual configuration/report cases.`);
} finally {
  fs.rmSync(temporary, { recursive: true, force: true });
}
