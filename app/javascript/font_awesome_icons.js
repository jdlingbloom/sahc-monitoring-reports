import { library, dom } from '@fortawesome/fontawesome-svg-core';
import { faPencilAlt } from '@fortawesome/free-solid-svg-icons/faPencilAlt';
import { faFile } from '@fortawesome/free-solid-svg-icons/faFile';
import { faTimes } from '@fortawesome/free-solid-svg-icons/faTimes';
import { faPlus } from '@fortawesome/free-solid-svg-icons/faPlus';

library.add(
  faPencilAlt,
  faFile,
  faTimes,
  faPlus,
);

dom.watch();
