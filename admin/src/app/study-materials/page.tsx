"use client";

import { ResourcePage } from "@/components/resource-page";
import { resources } from "@/lib/resources";

export default function StudyMaterialsPage() {
  return <ResourcePage resource={resources.studyMaterials} />;
}
