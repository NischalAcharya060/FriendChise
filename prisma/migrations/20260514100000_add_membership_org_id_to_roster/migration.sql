-- Add missing membershipOrgId column to RosterEntry and RosterTemplateEntry.
-- These composite FK fields were defined in schema.prisma but omitted from the
-- initial CREATE TABLE migrations. Back-fill from the membership's orgId via JOIN.

-- PostgreSQL requires a unique constraint on the referenced columns for a composite FK.
-- Membership.id is already the PK (unique), so (id, orgId) is always unique.
CREATE UNIQUE INDEX IF NOT EXISTS "Membership_id_orgId_key" ON "Membership"("id", "orgId");

-- RosterEntry: use IF NOT EXISTS in case the column was partially added by a prior failed migration
ALTER TABLE "RosterEntry" ADD COLUMN IF NOT EXISTS "membershipOrgId" TEXT;

UPDATE "RosterEntry" re
SET "membershipOrgId" = m."orgId"
FROM "Membership" m
WHERE m."id" = re."membershipId"
  AND re."membershipOrgId" IS NULL;

ALTER TABLE "RosterEntry" ALTER COLUMN "membershipOrgId" SET NOT NULL;

ALTER TABLE "RosterEntry"
  ADD CONSTRAINT "RosterEntry_membershipId_membershipOrgId_fkey"
  FOREIGN KEY ("membershipId", "membershipOrgId")
  REFERENCES "Membership"("id", "orgId")
  ON DELETE CASCADE ON UPDATE CASCADE;

-- RosterTemplateEntry
ALTER TABLE "RosterTemplateEntry" ADD COLUMN IF NOT EXISTS "membershipOrgId" TEXT;

UPDATE "RosterTemplateEntry" rte
SET "membershipOrgId" = m."orgId"
FROM "Membership" m
WHERE m."id" = rte."membershipId"
  AND rte."membershipOrgId" IS NULL;

ALTER TABLE "RosterTemplateEntry" ALTER COLUMN "membershipOrgId" SET NOT NULL;

ALTER TABLE "RosterTemplateEntry"
  ADD CONSTRAINT "RosterTemplateEntry_membershipId_membershipOrgId_fkey"
  FOREIGN KEY ("membershipId", "membershipOrgId")
  REFERENCES "Membership"("id", "orgId")
  ON DELETE CASCADE ON UPDATE CASCADE;
