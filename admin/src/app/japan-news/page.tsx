"use client";

import { ResourcePage } from "@/components/resource-page";
import { resources } from "@/lib/resources";

export default function JapanNewsPage() {
  return <ResourcePage resource={resources.news} />;
}
