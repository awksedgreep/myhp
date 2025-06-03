# Fly.io Deployment Guide

This guide walks through deploying your Phoenix LiveView application to Fly.io.

## Prerequisites

- flyctl CLI installed and authenticated
- Docker installed (for local testing)
- Phoenix app ready for production

## Deployment Steps

### 1. Initialize Fly App

```bash
fly launch
```

Follow the prompts but **don't deploy yet**. This creates your `fly.toml` configuration file.

### 2. Configure Secrets

Set your secret key base:

```bash
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
```

### 3. Create Persistent Volume

Create a volume for SQLite database persistence:

```bash
fly volumes create data --size 1
```

### 4. Deploy Application

```bash
fly deploy
```

### 5. Run Database Migrations

After successful deployment, run migrations:

```bash
fly ssh console -C "/app/bin/myhp eval 'Myhp.Release.migrate'"
```

### 6. Configure Admin Credentials

Set your admin credentials as secure Fly secrets:

```bash
fly secrets set ADMIN_EMAIL="your-admin@email.com" 
fly secrets set ADMIN_PASSWORD="your-secure-password"
```

### 7. Seed Database

Populate the database with initial data:

```bash
fly ssh console -C "/app/bin/myhp eval 'Myhp.Release.seed'"
```

## Admin Credentials

The seed script will create an admin user with the credentials you specified in the environment variables. Make sure to:
- Use a strong, unique password
- Store your credentials securely in a password manager
- Never commit actual credentials to your repository

## Important Notes

- Seeds don't run automatically on deploy - you must run them manually
- SQLite data persists in the `/app/data` volume
- Your Containerfile already handles static assets and health checks
- The app runs on port 4000 internally

## Troubleshooting

### Memory Issues
Phoenix apps can be memory-intensive. If needed, scale up:
```bash
fly scale memory 512
```

### Check Logs
```bash
fly logs
```

### Access Console
```bash
fly ssh console
```

## Pushing Updates

After making code changes, deploy updates with:

```bash
fly deploy
```

**Important**: If you have new database migrations, run them after deployment:

```bash
fly ssh console -C "/app/bin/myhp eval 'Myhp.Release.migrate'"
```

### Update Workflow

1. Make your code changes locally
2. Test locally: `mix phx.server`
3. Commit changes: `git add . && git commit -m "Your changes"`
4. Deploy: `fly deploy`
5. Run migrations (if any): `fly ssh console -C "/app/bin/myhp eval 'Myhp.Release.migrate'"`
6. Check deployment: `fly status` and `fly logs`

## Additional Configuration

You may need to create `lib/myhp/release.ex` with migrate and seed functions if they don't exist for the remote commands to work properly.