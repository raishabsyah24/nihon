"use client";

import { ResourcePage } from "@/components/resource-page";
import { resources } from "@/lib/resources";

export default function ExamSchedulesPage() {
  return <ResourcePage resource={resources.schedules} />;
}
