# static_website_in_S3

Terraform + S3 static website hosting example.

This repo provisions an Amazon S3 bucket configured for **Static Website Hosting** and serves the content in the `build/` folder (HTML/CSS/JS).

## Repository layout

- `build/` — static website files (e.g., `index.html`, `404.html`, `styles.css`, `script.js`)
- `provider.tf` — AWS provider configuration
- `s3.tf` — S3 bucket + website hosting configuration

---

## Prerequisites

- AWS account
- Terraform installed
- AWS credentials configured locally (one of the following):
  - `aws configure` (AWS CLI)
  - Environment variables `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
  - SSO profile (if your org uses it)

---

## 1) Deploy the S3 static website with Terraform

From the repo root:

```bash
terraform init
terraform plan
terraform apply
```

#-------------------------------------------------------------------

## Optional: Custom Domain

### Important Note (HTTPS)

The S3 static website endpoint does **not** support HTTPS directly.  
To use a custom domain **with HTTPS**, the standard architecture is:

**Route 53 (DNS) → CloudFront (CDN + TLS) → S3 (origin)**

---

## Option 1 (Recommended): Route 53 + CloudFront + ACM

### High-level steps

1. **Buy or own a domain**
   - You can register the domain in Route 53 or use any external registrar.

2. **Request an ACM certificate**
   - The certificate **must be created in `us-east-1`**, which is required by CloudFront.
   - Include the domain names you will use (e.g. `www.yourdomain.com`, optionally `yourdomain.com`).

3. **Create a CloudFront distribution**
   - **Origin**
     - Use your S3 bucket (website endpoint or bucket origin, depending on setup).
   - **Viewer protocol policy**
     - Redirect HTTP to HTTPS.
   - **Alternate domain names (CNAMEs)**
     - Example: `www.yourdomain.com`
   - **TLS certificate**
     - Attach the ACM certificate created in `us-east-1`.

4. **Configure DNS in Route 53**
   - Create an **A (and optionally AAAA) Alias record**
   - Point it to the CloudFront distribution.

5. **(Optional) Apex redirect**
   - Redirect `yourdomain.com` → `www.yourdomain.com`
   - Or configure both to work if desired.

This setup provides:
- HTTPS support
- Better performance via CDN caching
- Improved security posture

---

## Notes / Best Practices

- Consider keeping the S3 bucket **private** and serving content only through CloudFront for better control.
- Use CloudFront for HTTPS, performance, and global caching.
- S3 bucket names are **global**, so ensure your bucket name is unique.
