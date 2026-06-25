"use client";

import { ResourcePage } from "@/components/resource-page";
import { resources } from "@/lib/resources";

export default function JlptPage() {
  return <ResourcePage resource={resources.jlpt} />;
}
