"use client";

import { ResourcePage } from "@/components/resource-page";
import { resources } from "@/lib/resources";

export default function SswModulesPage() {
  return <ResourcePage resource={resources.sswModules} />;
}
