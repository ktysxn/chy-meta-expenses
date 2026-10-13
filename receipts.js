/* Accept phone-size files without embedding large originals in localStorage. */
(() => {
 const MAX=10*1024*1024, LOCAL=1500000, TARGET=1024*1024;
 const allowed=['image/jpeg','image/png','image/webp','image/heic','image/heif','application/pdf'];
 const mime=file=>file.type||({jpg:'image/jpeg',jpeg:'image/jpeg',png:'image/png',webp:'image/webp',heic:'image/heic',heif:'image/heif',pdf:'application/pdf'}[file.name.split('.').pop().toLowerCase()]||'');
 const read=blob=>new Promise((resolve,reject)=>{const r=new FileReader();r.onload=()=>resolve(r.result);r.onerror=()=>reject(Error('Unable to read this receipt.'));r.readAsDataURL(blob);});
 async function shrink(file){
  let image;try{image=await createImageBitmap(file);}catch{return null;}
  try{
   const canvas=document.createElement('canvas');let scale=Math.min(1,2600/Math.max(image.width,image.height));
   for(let attempt=0;attempt<5;attempt++){
    canvas.width=Math.max(1,Math.round(image.width*scale));canvas.height=Math.max(1,Math.round(image.height*scale));
    const ctx=canvas.getContext('2d');ctx.fillStyle='#fff';ctx.fillRect(0,0,canvas.width,canvas.height);ctx.drawImage(image,0,0,canvas.width,canvas.height);
    for(const quality of [.88,.78,.68]){const blob=await new Promise(r=>canvas.toBlob(r,'image/jpeg',quality));if(blob&&blob.size<=TARGET)return blob;}
    scale*=.8;
   }
   return null;
  }finally{image.close();}
 }
 fileData=async function(file){
  if(!file)return null;
  if(file.size>MAX)throw Error('Choose a receipt up to 10 MB.');
  const type=mime(file);if(!allowed.includes(type))throw Error('Choose a JPEG, PNG, WebP, HEIC, HEIF, or PDF receipt.');
  let blob=new Blob([file],{type}),name=file.name;
  if(blob.size>LOCAL&&type.startsWith('image/')){const compressed=await shrink(blob);if(compressed){blob=compressed;name=file.name.replace(/\.[^.]+$/,'')+'.jpg';}}
  if(blob.size>LOCAL){
   if(!window.cheyenneCloud?.prepareReceipt)throw Error('Sign in to cloud sync to attach a PDF or uncompressed image over 1.5 MB.');
   return await cheyenneCloud.prepareReceipt(blob,name);
  }
  return {name,data:await read(blob)};
 };
 const hint=document.createElement('p');hint.className='small';hint.textContent='Receipts up to 10 MB. Large photos are compressed automatically. Large PDFs and unsupported photo compression require an online cloud sign-in.';$('receiptInput').after(hint);
 window.cheyenneReceiptMime=mime;
})();
