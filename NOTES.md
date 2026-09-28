# NOTES.md

## Task 1 — Protected Instance

The instance chosen for `prevent_destroy = true` is **`app-server`**.

### Why app-server?

In a typical production setup, the `app-server` runs the core application
logic and is the most critical component of the infrastructure. Accidentally
destroying it would cause immediate downtime and potential data loss if it
holds any in-memory session state.

Other instances like `web-server` (load balancer/nginx) or `monitoring-server`
can be recreated quickly without major impact. The `db-server` ideally has its
own snapshot/backup strategy. But `app-server` sits in the middle of the stack
— losing it breaks everything between the frontend and the database.

This is why `prevent_destroy = true` is applied to it as a safety net.

---

## Task 2 — Remote State & Locking

### What happens today with local state (no backend)?

If two engineers run `terraform apply` at the same time with local state:
- Both read the same `terraform.tfstate` file locally
- Both calculate a diff and start making changes
- They overwrite each other's state file
- Result: **state corruption** — Terraform loses track of what actually
  exists in AWS, leading to duplicate resources, orphaned infrastructure,
  or failed future applies

### How S3 + DynamoDB backend fixes this:

- **S3** stores the state file in a single shared location — everyone reads
  and writes the same source of truth
- **DynamoDB** provides state locking — when one person runs `apply`,
  a lock entry is created in DynamoDB. Anyone else who tries to run `apply`
  simultaneously gets blocked with a "state locked" error until the first
  apply finishes
- This makes concurrent Terraform runs safe in a team environment

---

## Task 3 — IAM Users in Production

### Would you give `engine` and `ci` IAM users with access keys in real production?

**No.** IAM users with long-lived access keys are a security risk:
- Keys can be leaked in code, logs, or `.env` files
- There is no automatic rotation by default
- If compromised, they can be misused indefinitely until manually revoked

**What I would do instead:**

- For `ci` (CI pipeline): Use **OIDC federation** (e.g., GitHub Actions OIDC
  or GitLab OIDC) so the pipeline assumes an IAM role directly — no static
  keys needed at all
- For `engine` (a service/application): Use an **IAM Role attached to the
  EC2 instance or ECS task** — credentials are temporary and auto-rotated
  by AWS

Static IAM users with access keys should only exist as a last resort when
no better mechanism is available.

### Why does it matter to trust `roleB`'s ARN vs. the whole Account A root?

Trusting the entire Account A root (`arn:aws:iam::000000000000:root`) means
**any** principal in Account A — any user, role, or service — can assume
`roleC`, as long as Account A's admin grants them permission.

Trusting `roleB`'s specific ARN (`arn:aws:iam::000000000000:role/roleB`)
means **only roleB** can assume `roleC`. Even if someone in Account A has
broad permissions, they cannot assume `roleC` unless they first assume `roleB`.

This is the principle of least privilege applied to cross-account trust —
you minimize the blast radius if any Account A principal is compromised.

---

## Task 4 — What Was Deliberately Left Out of CI Policy

The CI policy was scoped to only what a pipeline needs:

| Left Out | Why |
|---|---|
| `ecr:DeleteRepository`, `ecr:BatchDeleteImage` | CI should push images, not delete them |
| `ecs:DeleteService`, `ecs:DeleteCluster` | CI should deploy, not destroy infrastructure |
| `s3:PutObject`, `s3:DeleteObject` on artifact bucket | CI only reads artifacts, never writes or deletes |
| `iam:*` | CI has no reason to touch IAM |
| `ec2:*` | Infrastructure changes go through Terraform, not CI |

The goal: if the CI pipeline is ever compromised, the attacker can push a
bad image and trigger a deploy — but they cannot delete infrastructure,
escalate privileges, or tamper with data.

---

## Task 5 — Bug Fix Explanation

Two bugs were found in the original snippet:

### Bug 1 — Trust Policy (Wrong principal type)

**Original:**
```hcl
identifiers = ["arn:aws:iam::000000000000:user/roleB"]
```

**Fixed:**
```hcl
identifiers = ["arn:aws:iam::000000000000:role/roleB"]
```

`roleB` is an IAM **Role**, not an IAM **User**. The ARN had `:user/roleB`
which points to a non-existent IAM user. The correct ARN uses `:role/roleB`.
Because of this, the trust policy was trusting a principal that does not
exist — meaning `roleB` could never assume `roleC`.

### Bug 2 — Permissions Policy (Overly broad S3 access)

**Original:**
```hcl
Action   = "s3:*"
Resource = "*"
```

**Fixed:**
```hcl
Action = [
  "s3:GetObject",
  "s3:PutObject",
  "s3:ListBucket"
]
Resource = [
  "arn:aws:s3:::my-specific-bucket",
  "arn:aws:s3:::my-specific-bucket/*"
]
```

`s3:*` on `Resource = "*"` gives full S3 access to every bucket in the
account — completely violating least privilege. The assignment said `roleC`
should have access to a **single named S3 bucket only**.
