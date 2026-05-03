const https = require('https');

/**
 * Fetches the latest version of a Terraform module from the Registry.
 * Usage: node update_module_versions.cjs terraform-aws-modules/vpc/aws
 */
async function getLatestVersion(modulePath) {
  const url = `https://registry.terraform.io/v1/modules/${modulePath}`;
  
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Gemini-CLI-Skill' } }, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        if (res.statusCode === 200) {
          const json = JSON.parse(data);
          resolve(json.version);
        } else {
          reject(new Error(`Terraform Registry error: ${res.statusCode}`));
        }
      });
    }).on('error', reject);
  });
}

const targetModule = process.argv[2];

if (!targetModule) {
  console.error("❌ Error: Please provide a module path (e.g., terraform-aws-modules/vpc/aws)");
  process.exit(1);
}

console.log(`🔍 Checking latest version for: ${targetModule}...`);

getLatestVersion(targetModule)
  .then(version => {
    console.log(`✅ Success: Latest stable version is ${version}`);
    // Output just the version at the end for easy parsing by the agent
    console.log(`VERSION_RESULT:${version}`);
  })
  .catch(err => {
    console.error(`❌ Failed: ${err.message}`);
    process.exit(1);
  });
