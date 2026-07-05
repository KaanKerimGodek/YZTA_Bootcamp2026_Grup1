import React, { useState } from 'react'; import { X, Check } from 'lucide-react'; export function Test(){ const [x]=useState(''); return <><X/><Check/>{x}</>; }
